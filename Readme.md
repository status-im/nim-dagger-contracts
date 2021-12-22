Dagger Contracts in Nim
=======================

Nim API for the [Dagger smart contracts][1].

Installation
------------

Use the [Nimble][2] package manager to add `daggercontracts` to an existing
project. Add the following to its .nimble file:

```nim
requires "https://github.com/status-im/nim-dagger-contracts.git >= 0.1.0 & < 0.2.0"
```

Testing
-------

If you wish to run the unit tests, make sure that you check out the
[dagger-contracts][1] repository next to this one. Then do the following:

```sh
# from the dagger-contracts directory, invoke:
npm install
npm start

# in another terminal, from the nim-dagger-contracts directory, invoke:
nimble test
```

Usage
-----

For a global overview of the steps involved in starting and fullfilling a
storage contract, see [Dagger Contracts][1].

Requests and bids
-----------------

Creating a storage request:

```nim
import daggercontracts

let request = StorageRequest(
  duration:     # duration of the contract (measured in ethereum blocks)
  size:         # size in bytes
  contentHash:  # SHA256 hash of the content that's going to be stored
  proofPeriod:  # average time between proofs (ethereum blocks)
  proofTimeout: # proofs must be submitted in this timeframe (ethereum blocks)
  nonce:        # random nonce used to differentiate between similar requests
)
```

Creating a storage bid:

```nim
let bid = StorageBid(
  requestHash: hashRequest(request),
  bidExpiry:  # expiration time of the bid (in unix time)
  price:      # offered price (in number of tokens)
)
```

Signing a storage request or bid:

```nim
import web3
import chronos

# Connect to an Ethereum node, and retrieve its accounts
let web3 = await newWeb3("ws://localhost:8545")
let accounts = await web3.getAccounts()

# Sign a request with the first account
let requestSignature = await web3.sign(accounts[0], hashRequest(request))

# Sign a bid with the second account
let bidSignature = await web3.sign(accounts[1], hashBid(bid))
```

Smart contract
--------------

Connecting to the smart contract on an Ethereum node:

```nim
let address = # fill in address where the contract was deployed
let storage = Storage.at(web3.provider, address)
```

Stakes
------

Hosts need to put up collateral (stake) before participating in storage
contracts.

A host can learn about the amount of stake that is required:
```nim
let stakeAmount = await storage.stakeAmount()
```

The host then needs to prepare a payment to the smart contract by calling the
`approve` method on the [ERC20 token][3]. Note that interaction with ERC20
contracts is not part of this library.

After preparing the payment, the host can lock up stake:
```nim
let host = # Ethereum account of the host that signed the bid

await storage
  .use(host)
  .increaseStake(stakeAmount)
```

When a host is not participating in storage contracts, it can release its stake:

```
await storage
  .use(host)
  .withdrawStake()
```

Starting a storage contract
---------------------------

When a client registers a new storage contract, it needs to pay the price of the
contract in advance. To prepare, the client needs to call the `approve` method
on the [ERC20 token][3]. Note that interaction with ERC20 contracts is not part
of this library.

Once the payment has been prepared, the client can register a new storage
contract:

```nim
let client = # Ethereum account of the client that signed the request

await storage
  .use(client)
  .newContract(request, bid, host, requestSignature, bidSignature)
```

The hash of the bid is used as an identifier to refer to this storage contract:
```nim
let id = hashBid(bid)
```

The host can start the storage contract once it received the data that needs to
be stored:

```nim
await storage
  .use(host)
  .startContract(id)
```

Storage proofs
--------------

For each new Ethereum block, the host can check whether a storage proof is
required:

```nim
let isProofRequired = await storage.isProofRequired(id, blocknumber)
```

If a proof is required, the host can submit it before the timeout:

```nim
await storage
  .use(host)
  .submitProof(id, blocknumber, proof)
```

If a proof is not submitted before the timeout, then a validator can mark
a proof as missing:

```nim
let validator = # Ethereum account of a validator

await storage
  .use(validator)
  .markProofAsMissing(id, blocknumber)
```

Once the storage contract is finished, the host can release payment:

```nim
await storage
  .use(host)
  .finishContract(id)
```

[1]: https://github.com/status-im/dagger-contracts/
[2]: https://github.com/nim-lang/nimble
[3]: https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
