targetScope = 'subscription'

param uniqueName string = 'spoke'
param SpokeVnetAddressPrefix array =  [
  '192.168.0.0/24'
]
param vmAdminUserName string
@secure()
param vmAdminPassword string

// Resource Group

var resourceGroupName = 'rg-${uniqueName}-level2-01'

module resourceGroup '../../../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-rg'
  params: {
    name: resourceGroupName
  }
}

module networkSecurityGroupSubnetDefault '../../../modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-nsg-sn-default'
  params: {
    name: 'nsg-sn-default-${uniqueName}-level2-01'
  }
  dependsOn: [
    resourceGroup
  ]
}

module virtualNetwork '../../../modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
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

module virtualMachine '../../../modules/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: '${uniqueString(deployment().name)}-vm'
  params: {
    name: 'vm-spoke'
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
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
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
