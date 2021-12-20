import pkg/web3
import pkg/stint

export stint

type BidHash = FixedBytes[32]

contract(Storage):
  proc stakeAmount: UInt256
  proc increaseStake(amount: UInt256)
  proc withdrawStake()
  proc stake(host: Address): UInt256
  proc newContract(
    duration: UInt256,
    size: UInt256,
    contentHash: FixedBytes[32],
    proofPeriod: UInt256,
    proofTimeout: UInt256,
    nonce: FixedBytes[32],
    price: UInt256,
    host: Address,
    bidExpiry: UInt256,
    requestSignature: DynamicBytes,
    bidSignature: DynamicBytes
  )
  proc duration(id: BidHash): UInt256
  proc size(id: BidHash): UInt256
  proc contentHash(id: BidHash): FixedBytes[32]
  proc proofPeriod(id: BidHash): UInt256
  proc proofTimeout(id: BidHash): UInt256
  proc price(id: BidHash): UInt256
  proc host(id: BidHash): Address
  proc startContract(id: BidHash)
  proc proofEnd(id: BidHash): UInt256
  proc isProofRequired(id: BidHash, blocknumber: UInt256): Bool
  proc submitProof(id: BidHash, blocknumber: UInt256, proof: Bool)
  proc finishContract(id: BidHash)
