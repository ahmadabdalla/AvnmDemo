targetScope = 'subscription'

var uniqueName = 'platform'
var SpokeVnetAddressPrefix = [
  '192.168.0.0/24'
]

module Config 'config.bicep' = {
  name: '${uniqueString(deployment().name)}-${uniqueName}-l2-config'
  params: {
    uniqueName: uniqueName
    SpokeVnetAddressPrefix: SpokeVnetAddressPrefix
  }
}
