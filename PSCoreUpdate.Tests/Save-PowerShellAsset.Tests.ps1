$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Save-PowerShellAsset unit tests" {

    BeforeAll {
        $Token = $env:GH_API_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GH_API_ACCESS_TOKEN is empty.'
        }
    }

    It "Returns nothing when specified invalid version" {
        Save-PowerShellAsset -Version 999.0.0 -AssetType ZIP_WIN64 -OutDirectory $TestDrive -Token $Token 3>&1 | Should -Not -BeNullOrEmpty
    }

    It "Returns error when invalid AssetType specified" {
        { Save-PowerShellAsset -Latest -AssetType Unknown -OutDirectory $TestDrive -Token $Token -ErrorAction Stop } | Should -Throw
        { Save-PowerShellAsset -Latest -AssetType MSI_WIN32, Unknown, MSI_WIN64 -OutDirectory $TestDrive -Token $Token -ErrorAction Stop } | Should -Throw
    }

    It "Should get single proper asset" {
        Save-PowerShellAsset -Version 6.0.0 -AssetType ZIP_WINARM64 -OutDirectory $TestDrive -Token $Token
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-win-arm64.zip' | Should -BeTrue
    }

    It "Should get multiple proper assets" {
        Save-PowerShellAsset -Version 6.0.0 -AssetType TAR_LINUXARM32, ZIP_WINARM32 -OutDirectory $TestDrive -Token $Token
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-linux-arm32.tar.gz' | Should -BeTrue
        Test-Path -LiteralPath 'TestDrive:\PowerShell-6.0.0-win-arm32.zip' | Should -BeTrue
    }
}