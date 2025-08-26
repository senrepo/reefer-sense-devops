@description('Name of the Container Apps Environment')
param environmentName string

@description('Location for the Container Apps Environment')
param location string = resourceGroup().location

@description('Name of the existing Virtual Network')
param vnetName string

@description('Name of the existing Subnet inside the VNet')
param subnetName string

@description('Name of the existing Log Analytics Workspace')
param logAnalyticsWorkspaceName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: subnetName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: subnet.id 
      internal: true
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

output containerAppEnvId string = containerAppEnvironment.id
output subnetId string = subnet.id
output logAnalyticsId string = logAnalyticsWorkspace.id
