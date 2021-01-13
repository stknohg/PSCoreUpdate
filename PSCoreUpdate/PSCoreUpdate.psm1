# Load messages
Import-LocalizedData -BindingVariable "Messages" -FileName "Messages"

# Import functions
. (Join-Path $PSScriptRoot 'Utils.ps1')
. (Join-Path $PSScriptRoot 'PowerShellCoreApiToken.ps1')
. (Join-Path $PSScriptRoot 'Find-PowerShellBuildStatus.ps1')
. (Join-Path $PSScriptRoot 'Find-PowerShellRelease.ps1')
. (Join-Path $PSScriptRoot 'Save-PowerShellAsset.ps1')
. (Join-Path $PSScriptRoot 'Test-LatestVersion.ps1')
. (Join-Path $PSScriptRoot 'Update-PowerShellCore.ps1')

# Set alias
Set-Alias -Name 'Download-PowerShellCore' -Value 'Save-PowerShellAsset'
# alias for compatibility
Set-Alias -Name 'Find-PowerShellCore' -Value 'Find-PowerShellRelease'
Set-Alias -Name 'Save-PowerShellCore' -Value 'Save-PowerShellAsset'
