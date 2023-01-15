targetScope = 'subscription'

param identifier string = 'B'
param spokeVnetAddressPrefix array = [
  '192.168.0.0/24'
]
param vnetXAddressPrefix array = [
  '192.168.1.0/24'
]
param vnetYAddressPrefix array =[
  '192.168.2.0/24'
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
