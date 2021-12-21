import pkg/chronos
import pkg/web3
import pkg/stint
import daggercontracts
import daggercontracts/testtoken
import ./web3test

web3suite "Staking":

  let stakeAmount = 100.u256

  var storage: Storage
  var token: Sender[TestToken]

  setup:
    let deployment = deployment()
    storage = Storage
      .at(web3.provider, deployment.address(Storage))
      .use(accounts[0])
    token = web3.contractSender(TestToken, deployment.address(TestToken))
    discard await token.mint(accounts[0], 1000.u256).send()

  test "increases stake":
    discard await token.approve(Address(storage.address), stakeAmount).send()
    await storage.increaseStake(stakeAmount)
    let stake = await storage.stake(accounts[0])
    check stake == stakeAmount

  test "withdraws stake":
    discard await token.approve(Address(storage.address), stakeAmount).send()
    await storage.increaseStake(stakeAmount)
    let balanceBefore = await token.balanceOf(accounts[0]).call()
    await storage.withdrawStake()
    let balanceAfter = await token.balanceOf(accounts[0]).call()
    check (balanceAfter - balanceBefore) == stakeAmount
