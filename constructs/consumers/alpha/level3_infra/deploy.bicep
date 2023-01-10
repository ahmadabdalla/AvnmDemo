targetScope = 'subscription'

var uniqueName = 'platform'
var ExtendedVnet1AddressPrefix = [
  '192.168.1.0/24'
]
var ExtendedVnet2AddressPrefix = [
  '192.168.2.0/24'
]


module Config 'config.bicep' = {
  name: '${uniqueString(deployment().name)}-${uniqueName}-l3-config'
  params: {
    uniqueName: uniqueName
    ExtendedVnet1AddressPrefix: ExtendedVnet1AddressPrefix
    ExtendedVnet2AddressPrefix: ExtendedVnet2AddressPrefix
  }
}
