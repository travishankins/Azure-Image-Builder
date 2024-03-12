param imageDefinitionName string
param location string
param computeGalleryName string

resource acg 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: computeGalleryName
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: imageDefinitionName
  location: location
  parent: acg
  properties: {
    architecture: 'x64'
    hyperVGeneration: 'V1'
    identifier: {
      offer: 'pro-byol'
      publisher: 'esri'
      sku: 'pro-byol-32'
    }
    osState: 'Generalized'
    osType: 'Windows'
    // Ensure the privacyStatementUri is set to a valid URI if available
    privacyStatementUri: 'https://www.esri.com/en-us/legal/privacy/overview'
  }
}
