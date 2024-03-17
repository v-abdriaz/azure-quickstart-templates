@description('Specifies the name of the deployment.')
param name string

@description('Specifies the name of the environment.')4
param environment string

@minLength(5)
param containerRegistryName string

@minLength(3)
@maxLength(24)
param storageAccountName string


@description('Specifies the location of the Azure Machine Learning workspace and dependent resources.')
@allowed([
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralus'
  'eastasia'
  'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'southeastasia'
  'southcentralus'
  'uksouth'
  'westcentralus'
  'westus'
  'westus2'
  'westeurope'
  'usgovvirginia'
])
param location string

var tenantId = subscription().tenantId
var keyVaultName = 'kv-${name}-${environment}'
var applicationInsightsName = 'appi-${name}-${environment}'
var workspaceName = 'mlw${name}${environment}'
var storageAccountId = storageAccount.id
var keyVaultId = keyVault.id
var applicationInsightId = applicationInsights.id
var containerRegistryId = containerRegistry.id

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  sku: {
    name: 'Standard'
  }
  location: location
  properties: {
    adminUserEnabled: false
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: workspaceName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightId
    containerRegistry: containerRegistryId
  }
}
