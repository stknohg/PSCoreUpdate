$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Save-PowerShellCore unit tests" {

    It "Returns nothing when specified invalid version" {
        Save-PowerShellCore -Version 999.0.0 -AssetType ZIP_WIN64 -OutDirectory $TestDrive 3>&1 | Should -Be 'No release found.'
    }

    It "Should get proper asset" {
        Save-PowerShellCore -Version 6.0.0 -AssetType ZIP_WIN64 -OutDirectory $TestDrive
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-win-x64.zip' | Should -BeTrue
    }

}