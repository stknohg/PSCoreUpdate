$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

InModuleScope 'PSCoreUpdate' {

    Describe "Update-PowerShellRelease unit tests" {

        BeforeAll {
            $Token = $env:GH_API_ACCESS_TOKEN
            if ([string]::IsNullOrEmpty($Token)) {
                Write-Host 'GH_API_ACCESS_TOKEN is empty.'
            }
        }
    
        $testCases = @(
            @{Pattern = '64bit'; Is64bit = $true; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.msi'},
            @{Pattern = '32bit'; Is64bit = $false; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.msi'}
        )
        It "GetMSIAssetUrls should get proper url (<Pattern>)" -TestCases $testCases {
            param($Pattern, $Is64bit, $DownloadUrl)

            Mock -CommandName IsCurrentProcess64bit -MockWith { return $Is64bit }
            
            $release = [PowerShellCoreRelease]::new()
            $release.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
            $asset = [PowerShellCoreAsset]::new()
            $asset.DownloadUrl = $DownloadUrl
            $release.Assets.Add($asset)
            GetMSIAssetUrls -Release $release | Should -Be $DownloadUrl
        }

        $testCases = @(
            @{Pattern = 'OSX El Capitan (10.11)'; DarwinVersion = 15; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/powershell-6.0.0-alpha.18-osx.10.11-x64.pkg'},
            @{Pattern = 'macOS Sierra (10.12) - PKG_OSX'; DarwinVersion = 16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-6.1.0-preview.3-osx.x64.pkg'},
            @{Pattern = 'macOS Sierra (10.12) - PKG_OSX1012'; DarwinVersion = 16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'}
            @{Pattern = 'macOS High Sierra (10.13) - PKG_OSX'; DarwinVersion = 17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-6.1.0-preview.3-osx.x64.pkg'},
            @{Pattern = 'macOS High Sierra (10.13) - PKG_OSX1012'; DarwinVersion = 17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'}
        )
        It "GetPKGAssetUrls should get proper url (<Pattern>)" -TestCases $testCases {
            param($Pattern, $DarwinVersion, $DownloadUrl)

            Mock -CommandName GetDarwinVersion -MockWith { return $DarwinVersion }
            
            $release = [PowerShellCoreRelease]::new()
            $release.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
            $asset = [PowerShellCoreAsset]::new()
            $asset.DownloadUrl = $DownloadUrl
            $release.Assets.Add($asset)
            GetPKGAssetUrls -Release $release | Should -Be $DownloadUrl
        }

        It "InstallMSI should set proper parameters (interactive)" {
            $params = @{
                NewVersion = '7.1.0'
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "C:\Temp\PowerShell-7.1.1-win-x64.msi"
                    InstallOptions = $null
                    Silent         = $false
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            $actual = (InstallMSI @params *>&1)[-1]
            # MSI default optional parameter is not orderd...
            $actual | Should -BeLike '(skip) msiexec.exe /i "C:\Temp\PowerShell-7.1.1-win-x64.msi"*ADD_PATH=1*'
            $actual | Should -BeLike '(skip) msiexec.exe /i "C:\Temp\PowerShell-7.1.1-win-x64.msi"*REGISTER_MANIFEST=1*'
        }

        It "InstallMSI should set proper parameters (silent)" {
            $params = @{
                NewVersion = '7.1.0'
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "C:\Temp\PowerShell-7.1.1-win-x64.msi"
                    InstallOptions = $null
                    Silent         = $true
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            $actual = (InstallMSI @params *>&1)[-1]
            # MSI default optional parameter is not orderd...
            $actual | Should -BeLike '(skip) msiexec.exe /i "C:\Temp\PowerShell-7.1.1-win-x64.msi" /passive*ADD_PATH=1*'
            $actual | Should -BeLike '(skip) msiexec.exe /i "C:\Temp\PowerShell-7.1.1-win-x64.msi" /passive*REGISTER_MANIFEST=1*'
        }

        It "InstallMSI should set proper parameters with custom options (interactive)" {
            $params = @{
                NewVersion = '7.1.0'
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "C:\Temp\PowerShell-7.1.1-win-x64.msi"
                    InstallOptions = [ordered]@{ Custom1="ABC"; Custom2="123" }
                    Silent         = $false
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            (InstallMSI @params *>&1)[-1] | Should -Be '(skip) msiexec.exe /i "C:\Temp\PowerShell-7.1.1-win-x64.msi" Custom1=ABC Custom2=123'
        }

        It "InstallPKG should set proper parameters (interactive)" {
            $params = @{
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "/tmp/powershell-7.1.1-osx-x64.pkg"
                    InstallOptions = $null
                    Silent         = $false
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            (InstallPKG @params *>&1)[-1] | Should -Be '(skip) Invoke-Item "/tmp/powershell-7.1.1-osx-x64.pkg"'
        }

        It "InstallPKG should set proper parameters (silent)" {
            $params = @{
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "/tmp/powershell-7.1.1-osx-x64.pkg"
                    InstallOptions = $null
                    Silent         = $true
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            (InstallPKG @params *>&1)[-1] | Should -Be '(skip) /usr/bin/sudo /usr/sbin/installer -pkg "/tmp/powershell-7.1.1-osx-x64.pkg" -target /'
        }

        It "InstallPKG should set proper parameters to install cutom volume (silent)" {
            $params = @{
                CommonParameters = [InstallCommonParameters]@{
                    InstallerPath  = "/tmp/powershell-7.1.1-osx-x64.pkg"
                    InstallOptions = [ordered]@{ target='/test-target/' }
                    Silent         = $true
                    ShouldProcess  = $false # this parameter must be false for testing
                }
            }
            (InstallPKG @params *>&1)[-1] | Should -Be '(skip) /usr/bin/sudo /usr/sbin/installer -pkg "/tmp/powershell-7.1.1-osx-x64.pkg" -target /test-target/'
        }
    }

}