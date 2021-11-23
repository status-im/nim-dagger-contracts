import pkg/web3
import pkg/stint

contract(Storage):
  proc increaseStake(amount: UInt256)
  proc stake(host: Address): UInt256
