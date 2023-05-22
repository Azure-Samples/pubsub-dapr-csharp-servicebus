param containerAppsEnvName string
param containerRegistryName string
param location string
param logAnalyticsWorkspaceName string
param serviceBusName string
param applicationInsightsName string = ''
param daprEnabled bool = false
param managedIdentityClientId string

// Container apps host (including container registry)
module containerApps '../core/host/container-apps.bicep' = {
  name: 'container-apps'
  params: {
    name: 'apps'
    containerAppsEnvironmentName: containerAppsEnvName
    containerRegistryName: containerRegistryName
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    applicationInsightsName: applicationInsightsName
    daprEnabled: daprEnabled
  }
}

// Get cApps Env resource instance to parent Dapr component config under it
resource caEnvironment  'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: containerAppsEnvName
}

resource daprComponentPubsub 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  parent: caEnvironment
  name: 'orderpubsub'
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'azureClientId'
        value: managedIdentityClientId  // See https://docs.dapr.io/developing-applications/integrations/azure/authenticating-azure/#credentials-metadata-fields for MSI
      }
      {
        name: 'namespaceName' // See https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus-topics/#spec-metadata-fields
        value: '${serviceBusName}.servicebus.windows.net' // the .servicebus.windows.net suffix is required as per dapr docs
      }
      {
        name: 'consumerID'
        value: 'orders' // Set to the same value of the subscription seen in ./servicebus.bicep
      }
    ]
    scopes: []
  }
  dependsOn: [
    containerApps
  ]
}

output environmentName string = containerApps.outputs.environmentName
output registryLoginServer string = containerApps.outputs.registryLoginServer
output registryName string = containerApps.outputs.registryName
