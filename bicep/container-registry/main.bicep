@description('Location for all resources')
param location string = resourceGroup().location

@description('Container Registry Name')
param containerRegistryName string = 'acrreeferdev'

@description('Policies configuration for the Container Registry')
param registryPolicies object = {
  adminUserEnabled: true
  quarantinePolicy: { status: 'disabled' }
  trustPolicy: { type: 'Notary', status: 'disabled' }
  retentionPolicy: { days: 7, status: 'disabled' }
  exportPolicy: { status: 'enabled' }
  azureADAuthenticationAsArmPolicy: { status: 'enabled' }
  softDeletePolicy: { retentionDays: 7, status: 'disabled' }
  encryption: { status: 'disabled' }
  publicNetworkAccess: 'Enabled'
  zoneRedundancy: 'Disabled'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    adminUserEnabled: registryPolicies.adminUserEnabled
    policies: {
      quarantinePolicy: registryPolicies.quarantinePolicy
      trustPolicy: registryPolicies.trustPolicy
      retentionPolicy: registryPolicies.retentionPolicy
      exportPolicy: registryPolicies.exportPolicy
      azureADAuthenticationAsArmPolicy: registryPolicies.azureADAuthenticationAsArmPolicy
      softDeletePolicy: registryPolicies.softDeletePolicy
    }
    encryption: registryPolicies.encryption
    publicNetworkAccess: registryPolicies.publicNetworkAccess
    zoneRedundancy: registryPolicies.zoneRedundancy
  }
}

@description('List of scope maps to create for the registry')
param scopeMaps array = [
  {
    name: '_repositories_admin'
    description: 'Can perform all read, write and delete operations on the registry'
    actions: [
      'repositories/*/metadata/read'
      'repositories/*/metadata/write'
      'repositories/*/content/read'
      'repositories/*/content/write'
      'repositories/*/content/delete'
    ]
  }
  {
    name: '_repositories_pull'
    description: 'Can pull any repository of the registry'
    actions: [
      'repositories/*/content/read'
    ]
  }
  {
    name: '_repositories_pull_metadata_read'
    description: 'Can perform all read operations on the registry'
    actions: [
      'repositories/*/content/read'
      'repositories/*/metadata/read'
    ]
  }
  {
    name: '_repositories_push'
    description: 'Can push to any repository of the registry'
    actions: [
      'repositories/*/content/read'
      'repositories/*/content/write'
    ]
  }
  {
    name: '_repositories_push_metadata_write'
    description: 'Can perform all read and write operations on the registry'
    actions: [
      'repositories/*/metadata/read'
      'repositories/*/metadata/write'
      'repositories/*/content/read'
      'repositories/*/content/write'
    ]
  }
]

@batchSize(1)
resource registryScopeMaps 'Microsoft.ContainerRegistry/registries/scopeMaps@2025-05-01-preview' = [for scope in scopeMaps: {
  parent: containerRegistry
  name: scope.name
  properties: {
    description: scope.description
    actions: scope.actions
  }
}]
