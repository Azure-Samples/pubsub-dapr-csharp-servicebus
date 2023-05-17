param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param name string = ''
param serviceName string = 'checkout'
param managedIdentityName string = ''

module publisher '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': 'checkout' })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    daprEnabled: true
    containerName: serviceName
    ingressEnabled: false
    identityType: 'UserAssigned'
    identityName: managedIdentityName
  }
}


output SERVICE_PUBLISHER_IMAGE_NAME string = publisher.outputs.imageName
output SERVICE_PUBLISHER_NAME string = publisher.outputs.name
