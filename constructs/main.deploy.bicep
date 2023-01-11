targetScope = 'subscription'

param vmAdminUserName string
@secure()
param vmAdminPassword string

module hub 'platform/level1_infra/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-hub'
  params: {
    vmAdminPassword: vmAdminUserName
    vmAdminUserName: vmAdminPassword
  }
}

module spoke 'consumer/level2_infra/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-spoke'
  params: {
    vmAdminPassword: vmAdminUserName
    vmAdminUserName: vmAdminPassword
  }
}

module extended 'consumer/level3_infra/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-extended'
  params: {
    vmAdminPassword: vmAdminUserName
    vmAdminUserName: vmAdminPassword
  }
}
