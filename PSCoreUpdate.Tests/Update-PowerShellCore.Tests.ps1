$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Update-PowerShellCore unit tests" {

    BeforeAll {
        $Token = $env:GITHUB_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GITHUB_ACCESS_TOKEN is empty.'
        }
    }
    
    # TODO : implement
}