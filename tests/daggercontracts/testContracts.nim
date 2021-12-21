import pkg/chronos
import daggercontracts
import daggercontracts/testtoken
import ./web3test
import ./examples

web3suite "Storage contracts":

  let (request, bid) = (StorageRequest, StorageBid).example

  var client, host: Address
  var storage: Storage
  var token: Sender[TestToken]
  var stakeAmount: UInt256

  setup:
    let deployment = deployment()
    client = accounts[0]
    host = accounts[1]
    storage = Storage.at(web3.provider, deployment.address(Storage))
    token = web3.contractSender(TestToken, deployment.address(TestToken))
    discard await token.mint(client, 1000.u256).send()
    discard await token.mint(host, 1000.u256).send()
    stakeAmount = await storage.stakeAmount()

  proc newContract(): Future[array[32, byte]] {.async.} =
    web3.defaultAccount = host
    storage = storage.use(host)
    discard await token.approve(Address(storage.address), stakeAmount).send()
    await storage.increaseStake(stakeAmount)
    web3.defaultAccount = client
    storage = storage.use(client)
    discard await token.approve(Address(storage.address), bid.price).send()
    let requestHash = hashRequest(request)
    let bidHash = hashBid(bid)
    let requestSignature = await web3.sign(client, requestHash)
    let bidSignature = await web3.sign(host, bidHash)
    await storage.newContract(
      request.duration,
      request.size,
      request.contentHash,
      request.proofPeriod,
      request.proofTimeout,
      request.nonce,
      bid.price,
      host,
      bid.bidExpiry,
      @requestSignature,
      @bidSignature
    )
    let id = bidHash
    return id

  proc minedBlockNumber(web3: Web3): Future[UInt256] {.async.} =
    let blocknumber = await web3.provider.ethBlockNumber()
    return blocknumber.uint64.u256

  proc mineUntilProofRequired(id: array[32, byte]): Future[UInt256] {.async.} =
    var blocknumber: UInt256
    var done = false
    while not done:
      blocknumber = await web3.minedBlockNumber()
      done = await storage.isProofRequired(id, blocknumber)
      if not done:
        discard await web3.provider.evmMine()
    return blocknumber

  proc mineUntilProofTimeout(id: array[32, byte]) {.async.} =
    let timeout = await storage.proofTimeout(id)
    for _ in 0..<timeout.truncate(int):
      discard await web3.provider.evmMine()

  proc mineUntilEnd(id: array[32, byte]) {.async.} =
    let proofEnd = await storage.proofEnd(id)
    while (await web3.minedBlockNumber()) < proofEnd:
      discard await web3.provider.evmMine()

  test "can be created":
    let id = await newContract()
    check (await storage.duration(id)) == request.duration
    check (await storage.size(id)) == request.size
    check (await storage.contentHash(id)) == request.contentHash
    check (await storage.proofPeriod(id)) == request.proofPeriod
    check (await storage.proofTimeout(id)) == request.proofTimeout
    check (await storage.price(id)) == bid.price
    check (await storage.host(id)) == host

  test "can be started by the host":
    let id = await newContract()
    storage = storage.use(host)
    await storage.startContract(id)
    let proofEnd = await storage.proofEnd(id)
    check proofEnd > 0

  test "accept storage proofs":
    let id = await newContract()
    storage = storage.use(host)
    await storage.startContract(id)
    let blocknumber = await mineUntilProofRequired(id)
    await storage.submitProof(id, blocknumber, Bool.parse(true))

  test "marks missing proofs":
    let id = await newContract()
    storage = storage.use(host)
    await storage.startContract(id)
    let blocknumber = await mineUntilProofRequired(id)
    await mineUntilProofTimeout(id)
    await storage.markProofAsMissing(id, blocknumber)

  test "can be finished":
    let id = await newContract()
    storage = storage.use(host)
    await storage.startContract(id)
    await mineUntilEnd(id)
    await storage.finishContract(id)
