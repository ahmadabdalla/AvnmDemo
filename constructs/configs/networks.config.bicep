targetScope = 'subscription'

param identifier string
param spokeVnetAddressPrefix array
param vnetXAddressPrefix array
param vnetYAddressPrefix array
param networkManagerName string
param networkManagerResourceGroupName string

// Resource Group

var resourceGroupName = 'rg-${identifier}'

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
    addressPrefixes: spokeVnetAddressPrefix
    name: 'vnet-spoke-${identifier}'
    subnets: [
      {
        addressPrefix: spokeVnetAddressPrefix[0]
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
    addressPrefixes: vnetXAddressPrefix
    name: 'vnet-x-${identifier}'
    subnets: [
      {
        addressPrefix: vnetXAddressPrefix[0]
        name: 'sn-default-${identifier}-vnet-x'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault_vnetX.outputs.resourceId
      }
    ]
  }
}

// VNET X

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
    addressPrefixes: vnetYAddressPrefix
    name: 'vnet-x-${identifier}'
    subnets: [
      {
        addressPrefix: vnetYAddressPrefix[0]
        name: 'sn-default-${identifier}-vnet-y'
        networkSecurityGroupId: networkSecurityGroupSubnetDefault_vnety.outputs.resourceId
      }
    ]
  }
}


// AVNM Existing Config

resource avnm 'Microsoft.Network/networkManagers@2022-07-01' existing = {
  scope: az.resourceGroup(networkManagerResourceGroupName)
  name: networkManagerName
}

// Network Group Resource

module avnm_networkGroup '../../modules/Microsoft.Network/networkManagers/networkGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-networkGroup'
  scope: az.resourceGroup(networkManagerResourceGroupName)
  params: {
    name: 'ng-${identifier}'
    description: 'Network Group - Identifier - ${identifier}'
    networkManagerName: avnm.name
  }
}

// Policy Definition (Microsoft.Network.Data - Subscription Scope)

module policyDefinition '../../modules/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyDefinition'
  params: {
    name: '[AVNM] pd-avnm-ng-${identifier}'
    mode: 'Microsoft.Network.Data'
    metadata: {
      Category: 'Azure Virtual Network Manager'
    }
    policyRule: {
      if: {
        allOf: [
          {
            value: '[subscription().SubscriptionId]'
            equals: subscription().id
          }
          {
            value: '[resourceGroup().Name]'
            contains: '-${identifier}-'
          }
        ]
      }
      then: {
        effect: 'addToNetworkGroup'
        details: {
          networkGroupId: avnm_networkGroup.outputs.resourceId
        }
      }
    }
  }
}

// Policy Assignment (Subscription Scope)

module policyAssignment '../../modules/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyAssignment'
  params: {
    name: '[AVNM] pa-avnm-ng-${identifier}'
    policyDefinitionId: policyDefinition.outputs.resourceId
  }
}
