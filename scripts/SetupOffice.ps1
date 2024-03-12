Write-Host "###### Starting Office 365/M365 installation script ######"

#region: Variables
$localPath = 'c:\temp\office'
$ODTDownloadURL = 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe'
$ODTInstaller = 'officedeploymenttool.exe'
$configXML = 'config-office.xml'
#endregion

#region: Create staging directory
if ((Test-Path c:\temp) -eq $false) {
    Write-Host "Creating C:\temp directory"
    New-Item -Path c:\temp -ItemType Directory
}
else {
    Write-Host "C:\temp directory already exists"
}

if ((Test-Path $localPath) -eq $false) {
    Write-Host "Creating $localPath directory"
    New-Item -Path $localPath -ItemType Directory
}
else {
    Write-Host "$localPath directory already exists"
}
#endregion

#region: Download and Extract ODT
Write-Host "Downloading Office Deployment Tool"
Invoke-WebRequest -Uri $ODTDownloadURL -OutFile "$localPath\$ODTInstaller"
Write-Host "Extracting Office Deployment Tool"
Start-Process -FilePath "$localPath\$ODTInstaller" -Args "/extract:$localPath" -Wait
#endregion

#region: Create Configuration XML File
$configContent = @"
<Configuration>
    <Add OfficeClientEdition="64" Channel="Monthly">
        <Product ID="O365ProPlusRetail">
            <Language ID="en-us" />
        </Product>
    </Add>
    <Property Name="SharedComputerLicensing" Value="1" />
    <Updates Enabled="TRUE" />
    <Display Level="None" AcceptEULA="TRUE" />
    <Logging Path="$localPath" />
</Configuration>
"@

$configContent | Out-File -FilePath "$localPath\$configXML"
Write-Host "Configuration XML file created"
#endregion

#region: Install Office 365/M365
Write-Host "Installing Office 365/M365"
Start-Process -FilePath "$localPath\setup.exe" -Args "/configure $localPath\$configXML" -Wait
#endregion

Write-Host "###### Office 365/M365 installation script is complete ######"
