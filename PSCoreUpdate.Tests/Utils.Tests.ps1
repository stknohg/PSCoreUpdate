$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
# Utils.ps1 is internal. so we need to dot source .ps1 file directly.
. (Join-Path $RootPath 'Utils.ps1')

Describe "PowerShellCoreAsset class unit tests" {
    $testCases = @(
        @{Expected = [AssetArchtectures]::MSI_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.msi'},
        @{Expected = [AssetArchtectures]::MSI_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-x86.msi'},
        @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.msi'},
        @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win10-win2016-x64.msi'},
        @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-win2008r2-x64.msi'},
        @{Expected = [AssetArchtectures]::PKG_OSX1011; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/powershell-6.0.0-alpha.18-osx.10.11-x64.pkg'},
        @{Expected = [AssetArchtectures]::PKG_OSX1012; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'},
        @{Expected = [AssetArchtectures]::RPM_RHEL7; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-1.rhel.7.x86_64.rpm'},
        @{Expected = [AssetArchtectures]::DEB_DEBIAN8; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.debian.8_amd64.deb'},
        @{Expected = [AssetArchtectures]::DEB_DEBIAN9; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.debian.9_amd64.deb'},
        @{Expected = [AssetArchtectures]::DEB_UBUNTU14; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.14.04_amd64.deb'},
        @{Expected = [AssetArchtectures]::DEB_UBUNTU16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.16.04_amd64.deb'},
        @{Expected = [AssetArchtectures]::DEB_UBUNTU17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb'},
        @{Expected = [AssetArchtectures]::APPIMAGE; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-x86_64.AppImage'},
        @{Expected = [AssetArchtectures]::TAR_LINUXARM32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-linux-arm32.tar.gz'},
        @{Expected = [AssetArchtectures]::TAR_LINUX64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-linux-x64.tar.gz'},
        @{Expected = [AssetArchtectures]::TAR_OSX; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx-x64.tar.gz'},
        @{Expected = [AssetArchtectures]::ZIP_WINARM32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-arm32.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WINARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-arm64.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-x86.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win10-win2016-x64.zip'},
        @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-win2008r2-x64.zip'},
        @{Expected = [AssetArchtectures]::Unknown; DownloadUrl = ''}
    )
    It "Should get proper asset architecture (<Expected>)" -TestCases $testCases {
        param($Expected, $DownloadUrl)

        $target = [PowerShellCoreAsset]::new()
        $target.DownloadUrl = $DownloadUrl
        $target.GetArchitecture() | Should -be $Expected
        $target.Architecture | Should -be $Expected
    }

}
