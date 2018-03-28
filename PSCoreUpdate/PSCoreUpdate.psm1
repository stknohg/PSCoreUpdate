# Import functions
. (Join-Path $PSScriptRoot 'Utils.ps1')
. (Join-Path $PSScriptRoot 'Find-PowerShellCore.ps1')
. (Join-Path $PSScriptRoot 'Save-PowerShellCore.ps1')
. (Join-Path $PSScriptRoot 'Test-LatestVersion.ps1')
. (Join-Path $PSScriptRoot 'Update-PowerShellCore.ps1')

# Set alias
Set-Alias -Name 'Download-PowerShellCore' -Value 'Save-PowerShellCore'
