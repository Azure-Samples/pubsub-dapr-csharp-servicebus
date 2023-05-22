param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param containerRegistryName string
param name string = ''
param serviceName string = 'orders'
param managedIdentityName string = ''
param exists bool = false
module subscriber '../core/host/container-app-upsert.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': 'orders' })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    exists: exists
    daprEnabled: true
    containerName: serviceName
    daprAppId: serviceName
    targetPort: 7001
    identityType: 'UserAssigned'
    identityName: managedIdentityName
  }
}


output SUBSCRIBER_URI string = subscriber.outputs.uri
output SERVICE_SUBSCRIBER_IMAGE_NAME string = subscriber.outputs.imageName
output SERVICE_SUBSCRIBER_NAME string = subscriber.outputs.name
