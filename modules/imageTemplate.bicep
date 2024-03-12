param imageTemplateName string
param location string
param identityName string
param vmSize string
param computeGalleryName string
param imageDefinitionName string
param sourceImagePublisher string
param sourceImageOffer string
param sourceImageSku string
param sourceImageVersion string
param diskSize int
param fslogixScriptURI string
param OptimizeOsScriptURI string
param teamsScriptURI string
param setupOfficeScriptURI string // Added parameter for Office script URI

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource acg 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: computeGalleryName
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 120
    source: {
      type: 'PlatformImage'
      publisher: sourceImagePublisher
      offer: sourceImageOffer
      sku: sourceImageSku
      version: sourceImageVersion
    }
    vmProfile: {
      osDiskSizeGB: diskSize
      vmSize: vmSize
    }
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${acg.id}/images/${imageDefinitionName}'
        runOutputName: 'acgOutput'
        replicationRegions: [
          location
        ]
      }
    ]
    customize: [
      {
        type: 'PowerShell'
        name: 'SetupFsLogix'
        runElevated: true
        runAsSystem: true
        scriptUri: fslogixScriptURI
      }
      {
        type: 'PowerShell'
        name: 'SetupTeams'
        runElevated: true
        runAsSystem: true
        scriptUri: teamsScriptURI
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host "Restarting post Teams installation"'
        restartTimeout: '5m'
      }
      {
        type: 'PowerShell'
        name: 'OptimizeOS'
        runElevated: true
        runAsSystem: true
        scriptUri: OptimizeOsScriptURI
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host "Restarting post OS Optimization"'
        restartTimeout: '5m'
      }
      // Added section for Office installation
      {
        type: 'PowerShell'
        name: 'SetupOffice'
        runElevated: true
        runAsSystem: true
        scriptUri: setupOfficeScriptURI
      }
      // Consider if another restart is needed after Office installation
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host "Restarting post Office installation"'
        restartTimeout: '5m'
      }
    ]
  }
}
