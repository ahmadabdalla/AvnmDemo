targetScope = 'subscription'

param uniqueName string
param SpokeVnetAddressPrefix array

// Resource Group

var resourceGroupName = 'rg-${uniqueName}-level2-01'

module resourceGroup '../../../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName
  }
}

module networkSecurityGroupSubnetDefault '../../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level2-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork '../../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet'
  params: {
    addressPrefixes: SpokeVnetAddressPrefix
    name: 'vnet-spoke-${uniqueName}-level2-01'
    subnets: [
      {
        addressPrefix: SpokeVnetAddressPrefix[0]
        name: 'sn-default-${uniqueName}-level2-01'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault.outputs.resourceId
      }
    ]
  }
}
