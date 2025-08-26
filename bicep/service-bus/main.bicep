@description('Location for all resources')
param location string = resourceGroup().location

@description('Service Bus Namespace name')
param servicebusNamespace string 

@description('List of queues to create inside the Service Bus namespace')
param queues array = [
  {
    name: 'iot-raw-data-queue'
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P7D'
    deadLetteringOnMessageExpiration: true
    maxDeliveryCount: 10
  }
  {
    name: 'iot-processed-data-queue'
    lockDuration: 'PT2M'
    maxSizeInMegabytes: 2048
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: true
    maxDeliveryCount: 5
  }
]

resource sbNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: servicebusNamespace
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource sbAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2024-01-01' = {
  name: 'RootManageSharedAccessKey'
  parent: sbNamespace
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource sbNetworkRules 'Microsoft.ServiceBus/namespaces/networkRuleSets@2024-01-01' = {
  name: 'default'
  parent: sbNamespace
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    trustedServiceAccessEnabled: false
  }
}

@batchSize(1)
resource sbQueues 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = [for queue in queues: {
  name: queue.name
  parent: sbNamespace
  properties: {
    lockDuration: queue.lockDuration
    maxSizeInMegabytes: queue.maxSizeInMegabytes
    defaultMessageTimeToLive: queue.defaultMessageTimeToLive
    deadLetteringOnMessageExpiration: queue.deadLetteringOnMessageExpiration
    enableBatchedOperations: true
    maxDeliveryCount: queue.maxDeliveryCount
    status: 'Active'
  }
}]
