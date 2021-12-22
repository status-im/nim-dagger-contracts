import pkg/web3
import pkg/json_rpc/rpcclient

type
  Contract*[Web3Contract] = object
    sender*: Sender[Web3Contract]
  EthAddress* = Address | array[20, byte]

proc at*[Web3Contract](T: type Contract[Web3Contract],
                       provider: RpcClient,
                       address: EthAddress): T =
  T(sender: newWeb3(provider).contractSender(Web3Contract, Address(address)))

func address*[Web3Contract](contract: Contract[Web3Contract]): array[20, byte] =
  array[20, byte](contract.sender.contractAddress)

proc use*[Web3Contract](contract: Contract[Web3Contract],
                        account: EthAddress): Contract[Web3Contract] =
  let provider = contract.sender.web3.provider
  let address = contract.address
  result = Contract[Web3Contract].at(provider, address)
  result.sender.web3.defaultAccount = Address(account)
