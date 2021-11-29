import pkg/stint
import pkg/contractabi
import pkg/nimcrypto
import pkg/chronos
import pkg/web3

type
  StorageRequest* = object
    duration*: UInt256
    size*: UInt256
    contentHash*: Hash
    proofPeriod*: UInt256
    proofTimeout*: UInt256
    nonce*: array[32, byte]
  StorageBid* = object
    requestHash*: Hash
    bidExpiry*: UInt256
    price*: UInt256
  Hash = array[32, byte]
  Signature = array[65, byte]

func hashRequest*(request: StorageRequest): Hash =
  var encoder = AbiEncoder.init
  encoder.write("[dagger.request.v1]")
  encoder.write(request.duration)
  encoder.write(request.size)
  encoder.write(request.contentHash)
  encoder.write(request.proofPeriod)
  encoder.write(request.proofTimeout)
  encoder.write(request.nonce)
  let encoding = encoder.finish
  keccak256.digest(encoding).data

func hashBid*(bid: StorageBid): Hash =
  var encoder = AbiEncoder.init
  encoder.write("[dagger.bid.v1]")
  encoder.write(bid.requestHash)
  encoder.write(bid.bidExpiry)
  encoder.write(bid.price)
  let encoding = encoder.finish
  keccak256.digest(encoding).data

proc sign*(web3: Web3,
           account: Address,
           hash: Hash): Future[Signature] {.async.} =
  let bytes = await web3.provider.ethSign(account, "0x" & hash.toHex)
  result[Signature.low..Signature.high] = bytes
