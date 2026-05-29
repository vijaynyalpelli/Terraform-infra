<#
  Sample PowerShell script to install IIS and deploy a simple index.html.
  This file is included for reference or for manual/hosted usage.
  When using Azure Custom Script Extension you can host this script on a URL and reference it via fileUris.
#>

# Exit on first error
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Installing IIS (Web-Server)..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Write-Host "Creating sample index.html..."
$sitePath = "C:\inetpub\wwwroot"
$html = @"
<html>
  <head><title>Terraform IIS Sample</title></head>
  <body>
    <h1>Terraform deployed this IIS site</h1>
    <p>Deployed on: $(Get-Date -Format o)</p>
  </body>
</html>
"@

# Ensure folder exists and write file
if (-not (Test-Path -Path $sitePath)) {
    New-Item -ItemType Directory -Path $sitePath -Force | Out-Null
}
Set-Content -Path (Join-Path $sitePath "index.html") -Value $html -Force

Write-Host "IIS installation and sample site deployment complete."
