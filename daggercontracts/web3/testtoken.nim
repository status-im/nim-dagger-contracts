import pkg/web3
import pkg/stint

contract(Web3TestToken):
  proc mint(holder: Address, amount: UInt256)
  proc approve(spender: Address, amount: UInt256)
  proc balanceOf(account: Address): UInt256
