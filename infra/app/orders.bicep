param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param name string = ''
param serviceName string = 'orders'
param managedIdentityName string = ''

module orders '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': 'orders' })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    daprEnabled: true
    containerName: serviceName
    targetPort: 7001
    managedIdentityEnabled: true
    managedIdentityName: managedIdentityName
  }
}


output ORDERS_URI string = orders.outputs.uri
output SERVICE_ORDERS_IMAGE_NAME string = orders.outputs.imageName
output SERVICE_ORDERS_NAME string = orders.outputs.name
