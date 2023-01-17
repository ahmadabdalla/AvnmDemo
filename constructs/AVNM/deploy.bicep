targetScope = 'subscription'

// Resource Group Configuration
param networkManagerName string = 'avnm-demo'
param resourceGroupName string
param hubVnetBastionSubnetAddressSpace string
param hubVirtualNetworkResourceId string
param alphaNetworksResourceGroupName string
param betaNetworksResourceGroupName string

module resourceGroup '../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-avnm-rg'
  params: {
    name: resourceGroupName
  }
}

module avnm '../../modules/Microsoft.Network/networkManagers/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-avnm-Config'
  params: {
    name: networkManagerName
    networkManagerScopeAccesses: [
      'Connectivity'
      'SecurityAdmin'
    ]
    networkManagerScopes: {
      subscriptions: [
        subscription().id
      ]
    }
  }
  dependsOn: [
    resourceGroup
  ]
}

/// Spokes Network Groups with Dynamic Members (via Azure Policy)

module networkGroup_Spokes '../../modules/Microsoft.Network/networkManagers/networkGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-networkGroup-Spokes'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'ng-spokes'
    description: 'Spokes Virtual Networks Group'
    networkManagerName: avnm.outputs.name
  }
}

module policyDefinition_Spokes '../../modules/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyDefinition-Spokes'
  params: {
    name: '[AVNM] pd-avnm-ng-spokes'
    mode: 'Microsoft.Network.Data'
    metadata: {
      Category: 'Azure Virtual Network Manager'
    }
    policyRule: {
      if: {
        allOf: [
          {
            value: '[subscription().SubscriptionId]'
            equals: subscription().subscriptionId
          }
          {
            field: 'Name'
            contains: 'vnet-spoke-'
          }
        ]
      }
      then: {
        effect: 'addToNetworkGroup'
        details: {
          networkGroupId: networkGroup_Spokes.outputs.resourceId
        }
      }
    }
  }
}

module policyAssignment_Spokes '../../modules/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyAssignment-Spokes'
  params: {
    name: '[AVNM] pa-avnm-ng-spokes'
    policyDefinitionId: policyDefinition_Spokes.outputs.resourceId
  }
}

/// Alpha Network Groups with Dynamic Members (via Azure Policy)

module networkGroup_Alpha '../../modules/Microsoft.Network/networkManagers/networkGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-networkGroup-Alpha'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'ng-alpha'
    description: 'Alpha Virtual Networks Group'
    networkManagerName: avnm.outputs.name
  }
}

module policyDefinition_Alpha '../../modules/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyDefinition-Alpha'
  params: {
    name: '[AVNM] pd-avnm-ng-alpha'
    mode: 'Microsoft.Network.Data'
    metadata: {
      Category: 'Azure Virtual Network Manager'
    }
    policyRule: {
      if: {
        allOf: [
          {
            value: '[subscription().SubscriptionId]'
            equals: subscription().subscriptionId
          }
          {
            value: '[resourceGroup().Name]'
            equals: alphaNetworksResourceGroupName
          }
        ]
      }
      then: {
        effect: 'addToNetworkGroup'
        details: {
          networkGroupId: networkGroup_Alpha.outputs.resourceId
        }
      }
    }
  }
}

module policyAssignment_Alpha '../../modules/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyAssignment-Alpha'
  params: {
    name: '[AVNM] pa-avnm-ng-alpha'
    policyDefinitionId: policyDefinition_Alpha.outputs.resourceId
  }
}

/// Beta Network Groups with Dynamic Members (via Azure Policy)

module networkGroup_Beta '../../modules/Microsoft.Network/networkManagers/networkGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-networkGroup-Beta'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'ng-beta'
    description: 'Beta Virtual Networks Group'
    networkManagerName: avnm.outputs.name
  }
  dependsOn: [
    avnm
  ]
}

module policyDefinition_Beta '../../modules/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyDefinition-Beta'
  params: {
    name: '[AVNM] pd-avnm-ng-beta'
    mode: 'Microsoft.Network.Data'
    metadata: {
      Category: 'Azure Virtual Network Manager'
    }
    policyRule: {
      if: {
        allOf: [
          {
            value: '[subscription().SubscriptionId]'
            equals: subscription().subscriptionId
          }
          {
            value: '[resourceGroup().Name]'
            equals: betaNetworksResourceGroupName
          }
        ]
      }
      then: {
        effect: 'addToNetworkGroup'
        details: {
          networkGroupId: networkGroup_Beta.outputs.resourceId
        }
      }
    }
  }
}

module policyAssignment_Beta '../../modules/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-PolicyAssignment-Beta'
  params: {
    name: '[AVNM] pa-avnm-ng-beta'
    policyDefinitionId: policyDefinition_Beta.outputs.resourceId
  }
}

/// Connectivity Config : Hub and Spoke 

module connectivityConfig_HubSpoke '../../modules/Microsoft.Network/networkManagers/connectivityConfigurations/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Conn-Config-Hub-Spoke'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    connectivityTopology: 'HubAndSpoke'
    name: 'config-connectivity-HubSpoke-vnets'
    networkManagerName: avnm.outputs.name
    description: 'Platform Zone and Managed Zone Hub-Spoke Connectivity Configuration'
    hubs: [
      {
        resourceId: hubVirtualNetworkResourceId
        resourceType: 'Microsoft.Network/virtualNetworks'
      }
    ]
    deleteExistingPeering: 'True'
    isGlobal: 'True'
    appliesToGroups: [
      {
        networkGroupId: networkGroup_Spokes.outputs.resourceId
        useHubGateway: 'False'
        groupConnectivity: 'None'
      }
    ]
  }
}

/// Connectivity Config : Mesh (Alpha)

module connectivityConfig_Mesh_Alpha '../../modules/Microsoft.Network/networkManagers/connectivityConfigurations/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Conn-Config-Mesh-Alpha'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    connectivityTopology: 'Mesh'
    name: 'config-connectivity-alpha-vnets'
    networkManagerName: avnm.outputs.name
    description: 'Connectivity Configuration - Mesh - Alpha Virtual Networks'
    deleteExistingPeering: 'False'
    isGlobal: 'True'
    appliesToGroups: [
      {
        networkGroupId: networkGroup_Alpha.outputs.resourceId
        useHubGateway: 'False'
        groupConnectivity: 'None'
      }
    ]
  }
}

/// Connectivity Config : Mesh (Beta)

module connectivityConfig_Mesh_Beta '../../modules/Microsoft.Network/networkManagers/connectivityConfigurations/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Conn-Config-Mesh-Beta'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    connectivityTopology: 'Mesh'
    name: 'config-connectivity-beta-vnets'
    networkManagerName: avnm.outputs.name
    description: 'Connectivity Configuration - Mesh - Beta Virtual Networks'
    deleteExistingPeering: 'False'
    isGlobal: 'True'
    appliesToGroups: [
      {
        networkGroupId: networkGroup_Beta.outputs.resourceId
        useHubGateway: 'False'
        groupConnectivity: 'None'
      }
    ]
  }
}


/// Security Admin Connectivity Config for Spoke Virtual Networks

module securityAdminConfig_Spokes '../../modules/Microsoft.Network/networkManagers/securityAdminConfigurations/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-SecurityAdmin-Config-Spokes'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'config-security-spokes'
    networkManagerName: avnm.outputs.name
    description: 'Security Admin Configuration for Spokes Virtual Networks'
    applyOnNetworkIntentPolicyBasedServices: [
      'None'
    ]
  }
}

module ruleCollection_securityAdminConfig_Spokes '../../modules/Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-RuleCollection-Spokes'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'rc-spokes-vnets'
    appliesToGroups: [
      {
        networkGroupId: networkGroup_Spokes.outputs.resourceId
      }
    ]
    networkManagerName: avnm.outputs.name
    securityAdminConfigurationName: securityAdminConfig_Spokes.outputs.name
    rules: [
      {
        name: 'Inbound-FROM-HubVnetBastion-TO-Any-P-RDPSSH-AlwaysAllow'
        sources: [
          {
            addressPrefixType: 'IPPrefix'
            addressPrefix: hubVnetBastionSubnetAddressSpace
          }
        ]
        access: 'AlwaysAllow'
        direction: 'Inbound'
        destinations: [
          {
            addressPrefix: '*'
          }
        ]
        destinationPortRanges: [
          '3389'
          '22'
        ]
        priority: 200
        protocol: 'Any'
      }
    ]
  }
}

/// Security Admin Connectivity Config for Alpha and Beta Virtual Networks

module securityAdminConfig_AlphaBeta '../../modules/Microsoft.Network/networkManagers/securityAdminConfigurations/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-SecurityAdmin-Config-AlphaBeta'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'config-security-alphabeta'
    networkManagerName: avnm.outputs.name
    description: 'Security Admin Configuration for Spokes Virtual Networks'
    applyOnNetworkIntentPolicyBasedServices: [
      'None'
    ]
  }
}

module ruleCollection_securityAdminConfig_AlphaBeta '../../modules/Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-RuleCollection-AlphaBeta'
  scope: az.resourceGroup(resourceGroupName)
  params: {
    name: 'rc-alphabeta-vnets'
    appliesToGroups: [
      {
        networkGroupId: networkGroup_Alpha.outputs.resourceId
      }
      {
        networkGroupId: networkGroup_Beta.outputs.resourceId
      }
    ]
    networkManagerName: avnm.outputs.name
    securityAdminConfigurationName: securityAdminConfig_AlphaBeta.outputs.name
    rules: [
      {
        name: 'Inbound-FROM-Any-TO-Any-P-RDPSSH-AlwaysAllow'
        sources: [
          {
            addressPrefix: '*'
          }
        ]
        access: 'Deny'
        direction: 'Inbound'
        destinations: [
          {
            addressPrefix: '*'
          }
        ]
        destinationPortRanges: [
          '3389'
          '22'
        ]
        priority: 210
        protocol: 'Any'
      }
    ]
  }
}
