@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Deployment environment (dev, prod)')
param environment string

@description('Data retention period in days (minimum 30, maximum 730)')
@minValue(30)
@maxValue(730)
param retentionDays int = 30

@description('Location for the workspace')
param location string = resourceGroup().location

// Combine base name + environment
var workspaceResourceName = '${workspaceName}-${environment}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceResourceName
  location: location
  properties: {
    retentionInDays: retentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceId string = logAnalytics.properties.customerId
output workspaceResourceId string = logAnalytics.id
