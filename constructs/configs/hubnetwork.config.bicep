targetScope = 'subscription'

param identifier string
param resourceGroupName_Hub string
param hubVnetAddressSpace string
param hubVnetBastionSubnetAddressSpace string
param hubVnetDefaultSubnetAddressSpace string

// Resource Group
module resourceGroup '../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName_Hub
  }
}

module nsg_subnet_bastion '../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName_Hub)
  name: '${uniqueString(deployment().name)}-nsg-sn-bastionSubnet-vnet-hub'
  dependsOn: [
    resourceGroup
  ]
  params: {
    name: 'nsg-sn-bastionSubnet-vnet-hub-${identifier}'
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

module nsg_subnet_default '../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName_Hub)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-vnet-hub'
  dependsOn: [
    resourceGroup
  ]
  params: {
    name: 'nsg-sn-default-vnet-hub-${identifier}'
  }
}

module virtualNetwork '../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName_Hub)
  name: '${uniqueString(deployment().name)}-vnet-hub'
  params: {
    addressPrefixes: [
      hubVnetAddressSpace
    ]
    name: 'vnet-hub-${identifier}'
    subnets: [
      {
        addressPrefix: hubVnetBastionSubnetAddressSpace
        name: 'AzureBastionSubnet'
        networkSecurityGroupId: nsg_subnet_bastion.outputs.resourceId
      }
      {
        addressPrefix: hubVnetDefaultSubnetAddressSpace
        name: 'sn-default-vnet-hub-${identifier}'
        networkSecurityGroupId: nsg_subnet_default.outputs.resourceId
      }
    ]
  }
}

module publicIpBastion '../../modules/Microsoft.Network/publicIPAddresses/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName_Hub)
  name: '${uniqueString(deployment().name)}-bst-pip'
  params: {
    name: 'pip-bst-vnet-hub-${identifier}'
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
  }
  dependsOn: [
    resourceGroup
  ]
}

module azureBastion '../../modules/Microsoft.Network/bastionHosts/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName_Hub)
  name: '${uniqueString(deployment().name)}-bst'
  params: {
    name: 'bst-vnet-hub-${identifier}'
    vNetId: virtualNetwork.outputs.resourceId
    skuType: 'Basic'
    isCreateDefaultPublicIP: false
    azureBastionSubnetPublicIpId: publicIpBastion.outputs.resourceId
  }
}

output hubVirtualNetworkResourceId string = virtualNetwork.outputs.resourceId
