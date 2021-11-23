import pkg/web3
import pkg/stint

contract(TestToken):
  proc mint(holders: Address, amount: UInt256)
  proc approve(spender: Address, amount: UInt256): bool
  proc balanceOf(account: Address): UInt256
