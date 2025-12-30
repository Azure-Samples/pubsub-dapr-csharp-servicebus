param location string 
param vnetName string 
param vnetPrefix string 
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: subnets
  }
}

@batchSize(1)
resource vnetSubnets 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = [ for subnet in subnets: {
  parent: vnet
  name: '${subnet.name}'
  properties: {
    addressPrefix: subnet.properties.addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}]

output vnetName string = vnet.name
