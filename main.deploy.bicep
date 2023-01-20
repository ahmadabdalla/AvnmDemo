targetScope = 'subscription'


/// Hub Virtual Network

param  identifier_Hub string = 'demo'
param  resourceGroupName_Hub string =  'rg-demo-hub'
param  hubVnetAddressSpace string = '10.0.0.0/16'
param  hubVnetBastionSubnetAddressSpace string = '10.0.0.0/24'
param  hubVnetDefaultSubnetAddressSpace string = '10.0.1.0/24'


module hub 'constructs/configs/hubnetwork.config.bicep' = {
  name: '${uniqueString(deployment().name)}-hub'
  params: {
    identifier: identifier_Hub
    resourceGroupName_Hub: resourceGroupName_Hub
    hubVnetAddressSpace: hubVnetAddressSpace
    hubVnetBastionSubnetAddressSpace: hubVnetBastionSubnetAddressSpace
    hubVnetDefaultSubnetAddressSpace: hubVnetDefaultSubnetAddressSpace
  }
}

/// Alpha Virtual Networks (Spokes + VNET X and VNET Y)

param identifier_Alpha string = 'alpha'
param resourceGroupName_Alpha string = 'rg-demo-alpha'
param spokeVnetAddressPrefix_alpha string = '172.16.0.0/24'
param vnetXAddressPrefix_alpha string = '172.16.1.0/24'
param vnetYAddressPrefix_alpha string = '172.16.2.0/24'

module alpha_networks 'constructs/configs/networks.config.bicep' = {
  name: '${uniqueString(deployment().name)}-identiier-Alpha'
  params: {
    identifier: identifier_Alpha
    resourceGroupName: resourceGroupName_Alpha
    spokeVnetAddressPrefixAndDefaultSubnet: spokeVnetAddressPrefix_alpha
    vnetXAddressPrefixAndDefaultSubnet: vnetXAddressPrefix_alpha
    vnetYAddressPrefixAndDefaultSubnet: vnetYAddressPrefix_alpha
  }
}

/// Beta Virtual Networks (Spokes + VNET X and VNET Y)

param identifier_Beta string = 'beta'
param resourceGroupName_Beta string = 'rg-demo-beta'
param spokeVnetAddressPrefix_beta string = '192.168.0.0/24'
param vnetXAddressPrefix_beta string = '192.168.1.0/24'
param vnetYAddressPrefix_beta string = '192.168.2.0/24'

module beta_networks 'constructs/configs/networks.config.bicep' = {
  name: '${uniqueString(deployment().name)}-identiier-Beta'
  params: {
    identifier: identifier_Beta
    resourceGroupName: resourceGroupName_Beta
    spokeVnetAddressPrefixAndDefaultSubnet: spokeVnetAddressPrefix_beta
    vnetXAddressPrefixAndDefaultSubnet: vnetXAddressPrefix_beta
    vnetYAddressPrefixAndDefaultSubnet: vnetYAddressPrefix_beta
  }
}

/// Azure Virtual Network Manager (AVNM)

module AVNM 'constructs/AVNM/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-AVNM'
  params: {
    hubVnetBastionSubnetAddressSpace: hubVnetBastionSubnetAddressSpace
    hubVirtualNetworkResourceId: hub.outputs.hubVirtualNetworkResourceId
    resourceGroupName_AVNM: 'rg-demo-avnm'
    alphaNetworksResourceGroupName: resourceGroupName_Alpha
    betaNetworksResourceGroupName: resourceGroupName_Beta
  }
}
