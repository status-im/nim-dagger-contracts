import std/os
import pkg/web3
import pkg/json_rpc/rpcclient

## Adds `evm_` methods from Ganache to the web3 provider,
## such as `evm_snapshot`.
## See also https://trufflesuite.github.io/ganache/

createRpcSigs(RpcClient, currentSourcePath.parentDir/"evmcallsigs.nim")
