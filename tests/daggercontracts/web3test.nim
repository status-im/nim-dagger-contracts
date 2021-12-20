import pkg/asynctest
import pkg/web3
import ./web3test/evm

export evm

# Allow multiple setups and teardowns in a test suite
template multisetup =

  var setups: seq[proc: Future[void] {.gcsafe.}]
  var teardowns: seq[proc: Future[void] {.gcsafe.}]

  setup:
    for setup in setups:
      await setup()

  teardown:
    for teardown in teardowns:
      await teardown()

  template setup(setupBody) {.inject.} =
    setups.add(proc {.async.} = setupBody)

  template teardown(teardownBody) {.inject.} =
    teardowns.insert(proc {.async.} = teardownBody)

## Unit testing suite that sets up a web3 testing environment.
## Injects a `web3` instance, and a list of `accounts`.
## Calls the Ganache `evm_snapshot` and `evm_revert` methods to ensure that any
## changes to the blockchain do not persist.
template web3suite*(name, body) =
  suite name:

    var web3 {.inject, used.}: Web3
    var accounts {.inject, used.}: seq[Address]
    var snapshot: UInt256

    multisetup()

    setup:
      web3 = await newWeb3("ws://localhost:8545")
      snapshot = await web3.provider.evmSnapshot()
      accounts = await web3.provider.ethAccounts()
      web3.defaultAccount = accounts[0]

    teardown:
      discard await web3.provider.evmRevert(snapshot)

    body

export evm
export web3
export asynctest
