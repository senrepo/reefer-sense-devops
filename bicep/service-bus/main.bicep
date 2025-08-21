@description('Location for all resources')
param location string = resourceGroup().location

@description('Servicebus name space')
param servicebusNamespace string = 'servicebus-ns-reefer-dev'

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: servicebusNamespace
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource servicebus_rootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2024-01-01' = {
  parent: servicebus
  name: 'RootManageSharedAccessKey'
  location: location
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource servicebus_network_ruleset 'Microsoft.ServiceBus/namespaces/networkrulesets@2024-01-01' = {
  parent: servicebus
  name: 'default'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource servicebus_iot_raw_data_queue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: servicebus
  name: 'iot-raw-data-queue'
  location: location
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P7D'
    deadLetteringOnMessageExpiration: true
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    enablePartitioning: false
    enableExpress: false
  }
}
