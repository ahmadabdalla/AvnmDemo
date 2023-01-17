targetScope = 'subscription'

param identifier string
param resourceGroupName string
param spokeVnetAddressPrefixAndDefaultSubnet string
param vnetXAddressPrefixAndDefaultSubnet string
param vnetYAddressPrefixAndDefaultSubnet string

// Resource Group

module resourceGroup '../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName
  }
}

// Spoke VNET

module networkSecurityGroupSubnetDefault_vnet_spoke '../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-vnet-spoke'
  params: {
    name: 'nsg-sn-default-${identifier}-vnet-spoke'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork_spoke '../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-spoke'
  params: {
    addressPrefixes: [
      spokeVnetAddressPrefixAndDefaultSubnet
    ]
    name: 'vnet-spoke-${identifier}'
    subnets: [
      {
        addressPrefix: spokeVnetAddressPrefixAndDefaultSubnet
        name: 'sn-default-${identifier}-vnet-spoke'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault_vnet_spoke.outputs.resourceId
      }
    ]
  }
}


// VNET X

module networkSecurityGroupSubnetDefault_vnetX '../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-vnet-x'
  params: {
    name: 'nsg-sn-default-${identifier}-vnet-x'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork_x '../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-x'
  params: {
    addressPrefixes: [
      vnetXAddressPrefixAndDefaultSubnet
    ]
    name: 'vnet-x-${identifier}'
    subnets: [
      {
        addressPrefix: vnetXAddressPrefixAndDefaultSubnet
        name: 'sn-default-${identifier}-vnet-x'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault_vnetX.outputs.resourceId
      }
    ]
  }
}

// VNET Y

module networkSecurityGroupSubnetDefault_vnety '../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-vnet-y'
  params: {
    name: 'nsg-sn-default-${identifier}-vnet-y'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork_y '../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-y'
  params: {
    addressPrefixes: [
      vnetYAddressPrefixAndDefaultSubnet
    ]
    name: 'vnet-y-${identifier}'
    subnets: [
      {
        addressPrefix: vnetYAddressPrefixAndDefaultSubnet
        name: 'sn-default-${identifier}-vnet-y'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault_vnety.outputs.resourceId
      }
    ]
  }
}
