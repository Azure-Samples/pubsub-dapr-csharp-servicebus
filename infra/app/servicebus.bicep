param resourceToken string
param location string
param skuName string = 'Standard'
param topicName string = 'orders'
param tags object


resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: 'sb-${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
  resource topic 'topics' = {
    name: topicName
    properties: {
      supportOrdering: true
    }

    resource subscription 'subscriptions' = {
      name: topicName
      properties: {
        deadLetteringOnFilterEvaluationExceptions: true
        deadLetteringOnMessageExpiration: true
        maxDeliveryCount: 10
      }
    }
  }
}

output SERVICEBUS_ENDPOINT string = serviceBusNamespace.properties.serviceBusEndpoint
output serviceBusName string = serviceBusNamespace.name
