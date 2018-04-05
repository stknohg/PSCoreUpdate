$RootPath = Join-Path $PSScriptRoot 'PSCoreUpdate'

# Validate module manifest
Test-ModuleManifest -Path (Join-Path $RootPath 'PSCoreUpdate.psd1') | Format-List
if (-not $?) {
    Write-Error 'Module manifest validation was failed.'
    exit 
}

# Publish
if ($null -eq $env:NUGET_API_KEY) {
    Write-Error 'NUGET_API_KEY environment variable not found.'
    exit 
}
Publish-Module -Path $RootPath -NugetApiKey $env:NUGET_API_KEY
