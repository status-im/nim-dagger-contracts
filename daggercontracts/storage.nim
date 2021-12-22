import pkg/web3
import pkg/json_rpc/rpcclient
import pkg/stint
import pkg/chronos
import ./web3/contract
import ./web3/storage
import ./marketplace

export stint
export contract

type
  Storage* = Contract[Web3Storage]
  Id = array[32, byte]

proc address*(storage: Storage): array[20, byte] =
  array[20, byte](storage.sender.contractAddress)

proc stakeAmount*(storage: Storage): Future[UInt256] =
  storage.sender.stakeAmount.call()

proc increaseStake*(storage: Storage, amount: UInt256) {.async.} =
  discard await storage.sender.increaseStake(amount).send()

proc withdrawStake*(storage: Storage) {.async.} =
  discard await storage.sender.withdrawStake().send()

proc stake*(storage: Storage, account: EthAddress): Future[UInt256] =
  storage.sender.stake(Address(account)).call()

proc newContract*(storage: Storage,
                  request: StorageRequest,
                  bid: StorageBid,
                  host: EthAddress,
                  requestSignature: array[65, byte],
                  bidSignature: array[65, byte]) {.async.} =
  let invocation = storage.sender.newContract(
    request.duration,
    request.size,
    FixedBytes[32](request.contentHash),
    request.proofPeriod,
    request.proofTimeout,
    FixedBytes[32](request.nonce),
    bid.price,
    Address(host),
    bid.bidExpiry,
    DynamicBytes[0, int.high](@requestSignature),
    DynamicBytes[0, int.high](@bidSignature)
  )
  discard await invocation.send()

proc duration*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.duration(FixedBytes[32](id)).call()

proc size*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.size(FixedBytes[32](id)).call()

proc contentHash*(storage: Storage, id: Id): Future[array[32, byte]] {.async.} =
  let hash = await storage.sender.contentHash(FixedBytes[32](id)).call()
  result = array[32, byte](hash)

proc proofPeriod*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.proofPeriod(FixedBytes[32](id)).call()

proc proofTimeout*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.proofTimeout(FixedBytes[32](id)).call()

proc price*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.price(FixedBytes[32](id)).call()

proc host*(storage: Storage, id: Id): Future[Address] =
  storage.sender.host(FixedBytes[32](id)).call()

proc startContract*(storage: Storage, id: Id) {.async.} =
  discard await storage.sender.startContract(FixedBytes[32](id)).send()

proc proofEnd*(storage: Storage, id: Id): Future[UInt256] =
  storage.sender.proofEnd(FixedBytes[32](id)).call()

proc isProofRequired*(storage: Storage,
                      id: Id,
                      blocknumber: UInt256): Future[bool] {.async.} =
  let sender = storage.sender
  let invocation = sender.isProofRequired(FixedBytes[32](id), blocknumber)
  result = ((await invocation.call()) == Bool.parse(true))

proc submitProof*(storage: Storage,
                  id: Id,
                  blocknumber: UInt256,
                  proof: bool) {.async.} =
  let sender = storage.sender
  let proof = Bool.parse(proof)
  let invocation = sender.submitProof(FixedBytes[32](id), blocknumber, proof)
  discard await invocation.send()

proc markProofAsMissing*(storage: Storage,
                          id: Id,
                          blocknumber: UInt256) {.async.} =
  let sender = storage.sender
  let invocation = sender.markProofAsMissing(FixedBytes[32](id), blocknumber)
  discard await invocation.send()

proc finishContract*(storage: Storage, id: Id) {.async.} =
  let invocation = storage.sender.finishContract(FixedBytes[32](id))
  discard await invocation.send()
