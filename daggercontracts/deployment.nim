import std/json
import pkg/web3

type Deployment* = object
  json: JsonNode

const defaultFile = "../dagger-contracts/deployment-localhost.json"

## Reads deployment information from a json file. It expects a file that has
## been exported with Hardhat deploy.
## See also:
## https://github.com/wighawag/hardhat-deploy/tree/master#6-hardhat-export
proc deployment*(file = defaultFile): Deployment =
  Deployment(json: parseFile(file))

proc address*(deployment: Deployment, Contract: typedesc): Address =
  let address = deployment.json["contracts"][$Contract]["address"].getStr()
  Address.fromHex(address)
