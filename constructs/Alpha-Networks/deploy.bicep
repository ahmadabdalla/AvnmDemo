targetScope = 'subscription'

param identifier string = 'A'
param spokeVnetAddressPrefix array = [
  '172.16.0.0/24'
]
param vnetXAddressPrefix array = [
  '172.16.1.0/24'
]
param vnetYAddressPrefix array =[
  '172.16.2.0/24'
]
param networkManagerName string = 'avnm-demo'
param networkManagerResourceGroupName string = 'rg-networking-demo'

module deployConfig '../configs/networks.config.bicep' = {
  name: '${uniqueString(deployment().name)}-identiier-${identifier}'
  params: {
    identifier: identifier
    spokeVnetAddressPrefix: spokeVnetAddressPrefix
    vnetXAddressPrefix: vnetXAddressPrefix
    vnetYAddressPrefix: vnetYAddressPrefix
    networkManagerName: networkManagerName
    networkManagerResourceGroupName: networkManagerResourceGroupName
  }
}
