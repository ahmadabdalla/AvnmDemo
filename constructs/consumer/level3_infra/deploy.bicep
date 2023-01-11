targetScope = 'subscription'

param uniqueName string = 'extended'
param ExtendedVnet1AddressPrefix array = [
  '192.168.1.0/24'
]
param ExtendedVnet2AddressPrefix array = [
  '192.168.2.0/24'
]
param vmAdminUserName string
@secure()
param vmAdminPassword string

// Resource Group

var resourceGroupName = 'rg-${uniqueName}-level3-01'

module resourceGroup '../../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName
  }
}

/// Extended VNET 1 Config

module networkSecurityGroupSubnetDefault1 '../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-1'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level3-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork1 '../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
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

module virtualMachine1 '../../../modules/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vm-1'
  params: {
    name: 'vm-extended-1'
    adminUsername: vmAdminUserName
    adminPassword: vmAdminPassword
    encryptionAtHost: false
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: virtualNetwork1.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_DS2_v2'
  }
}

/// Extended VNET 2 Config

module networkSecurityGroupSubnetDefault2 '../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default-2'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level3-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork2 '../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vnet-2'
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

module virtualMachine2 '../../../modules/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vm-2'
  params: {
    name: 'vm-extended-2'
    adminUsername: vmAdminUserName
    adminPassword: vmAdminPassword
    encryptionAtHost: false
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: virtualNetwork2.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_DS2_v2'
  }
}

