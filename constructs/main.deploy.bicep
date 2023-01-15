targetScope = 'subscription'

module hub 'Hub-Network/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Hub'
}

module Alpha 'Alpha-Networks/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Alpha'
}

module Beta 'Beta-Networks/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-Beta'
}
