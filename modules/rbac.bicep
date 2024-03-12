param identityName string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource contributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(identity.id, contributor.id)
  properties: {
    roleDefinitionId: contributor.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
