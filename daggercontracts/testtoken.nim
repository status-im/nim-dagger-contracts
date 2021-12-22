import pkg/chronos
import pkg/stint
import pkg/web3
import ./web3/contract
import ./web3/testtoken

export contract

type
  TestToken* = Contract[Web3TestToken]

proc mint*(token: TestToken, holder: EthAddress, amount: UInt256) {.async.} =
  discard await token.sender.mint(Address(holder), amount).send()

proc approve*(token: TestToken, spender: EthAddress, amount: UInt256) {.async.} =
  discard await token.sender.approve(Address(spender), amount).send()

proc balanceOf*(token: TestToken, account: EthAddress): Future[UInt256] =
  token.sender.balanceOf(Address(account)).call()
