import pkg/chronos
import daggercontracts
import daggercontracts/testtoken
import ./web3test
import ./web3types
import ./examples

web3suite "Storage contracts":

  let (request, bid) = (StorageRequest, StorageBid).example

  var client, host: Address
  var storage: Sender[Storage]
  var token: Sender[TestToken]
  var stakeAmount: UInt256

  setup:
    let deployment = deployment()
    storage = web3.contractSender(Storage, deployment.address(Storage))
    token = web3.contractSender(TestToken, deployment.address(TestToken))
    client = accounts[0]
    host = accounts[1]
    discard await token.mint(client, 1000.u256).send()
    discard await token.mint(host, 1000.u256).send()
    stakeAmount = await storage.stakeAmount.call()

  proc newContract(): Future[FixedBytes[32]] {.async.} =
    web3.defaultAccount = host
    discard await token.approve(storage.contractAddress, stakeAmount).send()
    discard await storage.increaseStake(stakeAmount).send()
    web3.defaultAccount = client
    discard await token.approve(storage.contractAddress, bid.price).send()
    let requestHash = hashRequest(request)
    let bidHash = hashBid(bid)
    let requestSignature = await web3.sign(client, requestHash)
    let bidSignature = await web3.sign(host, bidHash)
    discard await storage.newContract(
      request.duration,
      request.size,
      request.contentHash.toFixed,
      request.proofPeriod,
      request.proofTimeout,
      request.nonce.toFixed,
      bid.price,
      host,
      bid.bidExpiry,
      requestSignature.toDynamic,
      bidSignature.toDynamic
    ).send()
    let id = bidHash.toFixed
    return id

  proc minedBlockNumber(web3: Web3): Future[UInt256] {.async.} =
    let blocknumber = await web3.provider.ethBlockNumber()
    return blocknumber.uint64.u256

  proc mineUntilProofRequired(id: FixedBytes[32]): Future[UInt256] {.async.} =
    var blocknumber: UInt256
    var done = false
    while not done:
      blocknumber = await web3.minedBlockNumber()
      let isRequired = await storage.isProofRequired(id, blocknumber).call()
      done = (isRequired == Bool.parse(true))
      if not done:
        discard await web3.provider.evmMine()
    return blocknumber

  test "can be created":
    let id = await newContract()
    check (await storage.duration(id).call()) == request.duration
    check (await storage.size(id).call()) == request.size
    check (await storage.contentHash(id).call()).toArray == request.contentHash
    check (await storage.proofPeriod(id).call()) == request.proofPeriod
    check (await storage.proofTimeout(id).call()) == request.proofTimeout
    check (await storage.price(id).call()) == bid.price
    check (await storage.host(id).call()) == host

  test "can be started by the host":
    let id = await newContract()
    web3.defaultAccount = host
    discard await storage.startContract(id).send()
    let proofEnd = await storage.proofEnd(id).call()
    check proofEnd > 0

  test "accept storage proofs":
    let id = await newContract()
    web3.defaultAccount = host
    discard await storage.startContract(id).send()
    let blocknumber = await mineUntilProofRequired(id)
    discard await storage.submitProof(id, blocknumber, Bool.parse(true)).send()
