targetScope = 'subscription'

param identifier string = 'platform'
param  hubVnetAddressSpace array = [
  '10.0.0.0/24'
  '10.0.1.0/24'
]

module hub '../configs/hubnetwork.config.bicep' = {
  name: '${uniqueString(deployment().name)}-hub'
  params: {
    identifier: identifier
    hubVnetAddressSpace: hubVnetAddressSpace
    
  }
}
