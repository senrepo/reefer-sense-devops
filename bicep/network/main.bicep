@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual Network name')
param virtualNetworkName string

@description('Virtual Network address space')
param vnetAddressPrefixes array

@description('Subnet name for Private Endpoint')
param subnetPeName string

@description('Subnet address range for Private Endpoint')
param subnetPePrefixes array

@description('Subnet name for Azure Container Environment')
param subnetCaeName string

@description('Subnet address range for Azure Container Apps')
param subnetCaePrefixes array

// ----------------- VNET -----------------
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
  }
}

// ----------------- SUBNETS -----------------
resource subnetPe 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${vnet.name}/${subnetPeName}'
  properties: {
    addressPrefixes: subnetPePrefixes
  }
}

resource subnetAca 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${vnet.name}/${subnetCaeName}'
  properties: {
    addressPrefixes: subnetCaePrefixes
  }
}

// ----------------- OUTPUTS -----------------
output vnetId string = vnet.id
output subnetPeId string = subnetPe.id
output subnetAcaId string = subnetAca.id
