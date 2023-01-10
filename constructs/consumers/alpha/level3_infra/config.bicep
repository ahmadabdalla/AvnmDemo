targetScope = 'subscription'

param uniqueName string
param ExtendedVnet1AddressPrefix array
param ExtendedVnet2AddressPrefix array

// Resource Group

var resourceGroupName = 'rg-${uniqueName}-level3-01'

module resourceGroup '../../../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName
  }
}

/// Extended VNET 1 Config

module networkSecurityGroupSubnetDefault1 '../../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level3-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork1 '../../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-1'
  params: {
    addressPrefixes: ExtendedVnet1AddressPrefix
    name: 'vnet-ext-${uniqueName}-level3-01'
    subnets: [
      {
        addressPrefix: ExtendedVnet1AddressPrefix[0]
        name: 'sn-default-${uniqueName}-level3-01'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault1.outputs.resourceId
      }
    ]
  }
}

/// Extended VNET 2 Config

module networkSecurityGroupSubnetDefault2 '../../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level3-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork2 '../../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-1'
  params: {
    addressPrefixes: ExtendedVnet2AddressPrefix
    name: 'vnet-ext-${uniqueName}-level3-01'
    subnets: [
      {
        addressPrefix: ExtendedVnet2AddressPrefix[0]
        name: 'sn-default-${uniqueName}-level3-01'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault2.outputs.resourceId
      }
    ]
  }
}
