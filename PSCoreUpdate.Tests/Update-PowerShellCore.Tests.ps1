$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

InModuleScope 'PSCoreUpdate' {

    Describe "Update-PowerShellCore unit tests" {

        BeforeAll {
            $Token = $env:GITHUB_ACCESS_TOKEN
            if ([string]::IsNullOrEmpty($Token)) {
                Write-Host 'GITHUB_ACCESS_TOKEN is empty.'
            }
        }
    
        $testCases = @(
            @{Pattern = '64bit'; Is64bit = $true; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.msi'},
            @{Pattern = '32bit'; Is64bit = $false; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.msi'}
        )
        It "GetMSIDownloadUrl should get proper url (<Pattern>)" -TestCases $testCases {
            param($Pattern, $Is64bit, $DownloadUrl)

            Mock -CommandName IsCurrentProcess64bit -MockWith { return $Is64bit }
            
            $release = [PowerShellCoreRelease]::new()
            $release.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
            $asset = [PowerShellCoreAsset]::new()
            $asset.DownloadUrl = $DownloadUrl
            $release.Assets.Add($asset)
            GetMSIDownloadUrl -Release $release | Should -Be $DownloadUrl
        }

        $testCases = @(
            @{Pattern = 'OSX El Capitan (10.11)'; DarwinVersion = 15; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/powershell-6.0.0-alpha.18-osx.10.11-x64.pkg'},
            @{Pattern = 'macOS Sierra (10.12) - PKG_OSX'; DarwinVersion = 16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-6.1.0-preview.3-osx.x64.pkg'},
            @{Pattern = 'macOS Sierra (10.12) - PKG_OSX1012'; DarwinVersion = 16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'}
            @{Pattern = 'macOS High Sierra (10.13) - PKG_OSX'; DarwinVersion = 17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-6.1.0-preview.3-osx.x64.pkg'},
            @{Pattern = 'macOS High Sierra (10.13) - PKG_OSX1012'; DarwinVersion = 17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'}
        )
        It "GetPKGDownloadUrl should get proper url (<Pattern>)" -TestCases $testCases {
            param($Pattern, $DarwinVersion, $DownloadUrl)

            Mock -CommandName GetDarwinVersion -MockWith { return $DarwinVersion }
            
            $release = [PowerShellCoreRelease]::new()
            $release.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
            $asset = [PowerShellCoreAsset]::new()
            $asset.DownloadUrl = $DownloadUrl
            $release.Assets.Add($asset)
            GetPKGDownloadUrl -Release $release | Should -Be $DownloadUrl
        }
    }

}