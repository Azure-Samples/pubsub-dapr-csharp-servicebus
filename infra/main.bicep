targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// App based params
param checkoutContainerAppName string = ''
param checkoutServiceName string = 'checkout'
param ordersContainerAppName string = ''
param ordersServiceName string = 'orders'
param checkoutImageName string = ''
param ordersImageName string = ''

param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param logAnalyticsName string = ''


param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''

param resourceGroupName string = ''
// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }


// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

module serviceBusResources './app/servicebus.bicep' = {
  name: 'sb-resources'
  scope: rg
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    skuName: 'Standard'
  }
}

module serviceBusAccess './app/servicebus-access.bicep' = {
  name: 'sb-access'
  scope: rg
  params: {
    location: location
    serviceBusName: serviceBusResources.outputs.serviceBusName
    managedIdentityName: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
  }
}


// Shared App Env with Dapr configuration for db
module appEnv './app/app-env.bicep' = {
  name: 'app-env'
  scope: rg
  params: {
    containerAppsEnvName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
    serviceBusName: serviceBusResources.outputs.serviceBusName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    daprEnabled: true
    manegeIdentityClientId: serviceBusAccess.outputs.managedIdentityClientlId
  }
}

module checkoutApp './app/checkout.bicep' = {
  name: 'api-resources'
  scope: rg
  params: {
    name: !empty(checkoutContainerAppName) ? checkoutContainerAppName : '${abbrs.appContainerApps}${checkoutServiceName}-${resourceToken}'
    serviceName: checkoutServiceName
    containerRegistryName: appEnv.outputs.registryName
    imageName: checkoutImageName
    location: location
    containerAppsEnvironmentName: appEnv.outputs.environmentName
    managedIdentityName: serviceBusAccess.outputs.managedIdentityName
  }
  dependsOn: [
    ordersApp  // Deploy the subscriber first and then deploy the publisher
  ]
}

module ordersApp './app/orders.bicep' = {
  name: 'web-resources'
  scope: rg
  params: {
    name: !empty(ordersContainerAppName) ? ordersContainerAppName : '${abbrs.appContainerApps}${ordersServiceName}-${resourceToken}'
    location: location
    imageName: ordersImageName
    containerRegistryName: appEnv.outputs.registryName
    containerAppsEnvironmentName: appEnv.outputs.environmentName
    serviceName: ordersServiceName
    managedIdentityName: serviceBusAccess.outputs.managedIdentityName
  }
}


output SERVICE_CHECKOUT_NAME string = checkoutApp.outputs.SERVICE_CHECKOUT_NAME
output SERVICE_ORDERS_NAME string = ordersApp.outputs.SERVICE_ORDERS_NAME
output ORDERS_APP_URI string = ordersApp.outputs.ORDERS_URI
output SERVICEBUS_ENDPOINT string = serviceBusResources.outputs.SERVICEBUS_ENDPOINT
output SERVICEBUS_NAME string = serviceBusResources.outputs.serviceBusName
output APPINSIGHTS_INSTRUMENTATIONKEY string = monitoring.outputs.applicationInsightsInstrumentationKey
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output AZURE_CONTAINER_ENVIRONMENT_NAME string = appEnv.outputs.environmentName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = appEnv.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = appEnv.outputs.registryName
output AZURE_MANAGED_IDENTITY_NAME string = serviceBusAccess.outputs.managedIdentityName
