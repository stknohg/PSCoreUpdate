$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Save-PowerShellCore unit tests" {

    BeforeAll {
        $Token = $env:GITHUB_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GITHUB_ACCESS_TOKEN is empty.'
        }
    }

    It "Returns nothing when specified invalid version" {
        Save-PowerShellCore -Version 999.0.0 -AssetType ZIP_WIN64 -OutDirectory $TestDrive -Token $Token 3>&1 | Should -Be 'No release found.'
    }

    It "Returns error when invalid AssetType specified" {
        { Save-PowerShellCore -Latest -AssetType Unknown -OutDirectory $TestDrive -Token $Token -ErrorAction Stop } | Should -Throw 'Invalid AssetType.'
        { Save-PowerShellCore -Latest -AssetType MSI_WIN32, Unknown, MSI_WIN64 -OutDirectory $TestDrive -Token $Token -ErrorAction Stop } | Should -Throw 'Invalid AssetType included.'

    }

    It "Should get single proper asset" {
        Save-PowerShellCore -Version 6.0.0 -AssetType ZIP_WINARM64 -OutDirectory $TestDrive -Token $Token
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-win-arm64.zip' | Should -BeTrue
    }

    It "Should get multiple proper assets" {
        Save-PowerShellCore -Version 6.0.0 -AssetType TAR_LINUXARM32, ZIP_WINARM32 -OutDirectory $TestDrive -Token $Token
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-linux-arm32.tar.gz' | Should -BeTrue
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-win-arm32.zip' | Should -BeTrue
    }
}