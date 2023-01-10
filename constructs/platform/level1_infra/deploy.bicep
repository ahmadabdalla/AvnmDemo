targetScope = 'subscription'

var uniqueName = 'platform'
var hubVnetAddressSpace = [
  '10.0.0.0/24'
]

module Config 'config.bicep' = {
  name: '${uniqueString(deployment().name)}-${uniqueName}-l1-config'
  params: {
    uniqueName: uniqueName
    hubVnetAddressSpace: hubVnetAddressSpace
  }
}
