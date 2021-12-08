import pkg/asynctest
import pkg/chronos
import pkg/nimcrypto
import pkg/contractabi
import daggercontracts
import ./web3test
import ./examples

suite "Marketplace":

  test "hashes requests for storage":
    let request = StorageRequest.example
    let encoding = AbiEncoder.encode: (
      "[dagger.request.v1]",
      request.duration,
      request.size,
      request.contentHash,
      request.proofPeriod,
      request.proofTimeout,
      request.nonce
    )
    let expectedHash = keccak256.digest(encoding).data
    check hashRequest(request) == expectedHash

  test "hashes bids":
    let bid = StorageBid.example
    let encoding = AbiEncoder.encode: (
      "[dagger.bid.v1]",
      bid.requestHash,
      bid.bidExpiry,
      bid.price
    )
    let expectedHash = keccak256.digest(encoding).data
    check hashBid(bid) == expectedHash

web3suite "Marketplace signatures":

  test "signs request and bid hashes":
    let hash = hashRequest(StorageRequest.example)
    let signature = await web3.sign(accounts[0], hash)
    check signature.len == 65
    check signature != array[65, byte].default
