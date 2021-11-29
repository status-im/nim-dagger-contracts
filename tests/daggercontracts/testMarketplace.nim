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
    var encoder = AbiEncoder.init()
    encoder.write("[dagger.request.v1]")
    encoder.write(request.duration)
    encoder.write(request.size)
    encoder.write(request.contentHash)
    encoder.write(request.proofPeriod)
    encoder.write(request.proofTimeout)
    encoder.write(request.nonce)
    let encoding = encoder.finish()
    let expectedHash = keccak256.digest(encoding).data
    check hashRequest(request) == expectedHash

  test "hashes bids":
    let bid = StorageBid.example
    var encoder = AbiEncoder.init()
    encoder.write("[dagger.bid.v1]")
    encoder.write(bid.requestHash)
    encoder.write(bid.bidExpiry)
    encoder.write(bid.price)
    let encoding = encoder.finish()
    let expectedHash = keccak256.digest(encoding).data
    check hashBid(bid) == expectedHash

web3suite "Marketplace signatures":

  test "signs request and bid hashes":
    let hash = hashRequest(StorageRequest.example)
    let signature = await web3.sign(accounts[0], hash)
    check signature.len == 65
    check signature != array[65, byte].default
