param managedIdentityName string
param serviceBusName string
param location string


// See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-sender
var roleIdS = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender
// See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver
var roleIdR = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' // Azure Service Bus Data Receiver

// user assigned managed identity to use throughout
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
}

// Grant permissions to the managedIdentity to specific role to servicebus
resource roleAssignmentReceiver 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(serviceBus.id, roleIdR, managedIdentityName)
  scope: serviceBus
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdR)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal' // managed identity is a form of service principal
  }
  dependsOn: [
    serviceBus
  ]
}

// Grant permissions to the managedIdentity to specific role to servicebus
resource roleAssignmentSender 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(serviceBus.id, roleIdS, managedIdentityName)
  scope: serviceBus
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdS)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal' // managed identity is a form of service principal
  }
  dependsOn: [
    serviceBus
  ]
}

output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityClientlId string = managedIdentity.properties.clientId
output managedIdentityId string = managedIdentity.id
output managedIdentityName string = managedIdentity.name
