import pkg/chronos
import pkg/stint
import daggercontracts
import daggercontracts/testtoken
import ./web3test

web3suite "Staking":

  let stakeAmount = 100.u256

  var storage: Storage
  var token: TestToken

  setup:
    let deployment = deployment()
    storage = Storage
      .at(web3.provider, deployment.address(Storage))
      .use(accounts[0])
    token = TestToken
      .at(web3.provider, deployment.address(TestToken))
      .use(accounts[0])
    await token.mint(accounts[0], 1000.u256)

  test "increases stake":
    await token.approve(storage.address, stakeAmount)
    await storage.increaseStake(stakeAmount)
    let stake = await storage.stake(accounts[0])
    check stake == stakeAmount

  test "withdraws stake":
    await token.approve(storage.address, stakeAmount)
    await storage.increaseStake(stakeAmount)
    let balanceBefore = await token.balanceOf(accounts[0])
    await storage.withdrawStake()
    let balanceAfter = await token.balanceOf(accounts[0])
    check (balanceAfter - balanceBefore) == stakeAmount
