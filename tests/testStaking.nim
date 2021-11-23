import pkg/chronos
import pkg/web3
import pkg/stint
import daggercontracts
import daggercontracts/testtoken
import ./web3test

web3suite "Staking":

  let stakeAmount = 100.u256

  var storage: Sender[Storage]
  var token: Sender[TestToken]

  setup:
    let deployment = deployment()
    storage = web3.contractSender(Storage, deployment.address(Storage))
    token = web3.contractSender(TestToken, deployment.address(TestToken))
    discard await token.mint(accounts[0], 1000.u256).send()

  test "increases stake":
    discard await token.approve(storage.contractAddress, stakeAmount).send()
    discard await storage.increaseStake(stakeAmount).send()
    let stake = await storage.stake(accounts[0]).call()
    check stake == stakeAmount
