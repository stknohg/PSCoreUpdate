$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

InModuleScope 'PSCoreUpdate' {
    Describe "PowerShellCoreAsset class unit tests" {
        $testCases = @(
            @{Expected = [AssetArchtectures]::HASHES_SHA256; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-rc.1/hashes.sha256'},
            @{Expected = [AssetArchtectures]::MSI_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.msi'},
            @{Expected = [AssetArchtectures]::MSI_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-x86.msi'},
            @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.msi'},
            @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win10-win2016-x64.msi'},
            @{Expected = [AssetArchtectures]::MSI_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-win2008r2-x64.msi'},
            @{Expected = [AssetArchtectures]::MSI_ARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.3/PowerShell-7.4.3-win-arm64.msi'},
            @{Expected = [AssetArchtectures]::MSIX_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/PowerShell-7.0.2-win-x86.msix'},
            @{Expected = [AssetArchtectures]::MSIX_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/PowerShell-7.0.2-win-x64.msix'},
            @{Expected = [AssetArchtectures]::MSIX_WINARM32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/PowerShell-7.0.2-win-arm32.msix'},
            @{Expected = [AssetArchtectures]::MSIX_WINARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/PowerShell-7.0.2-win-arm64.msix'},
            @{Expected = [AssetArchtectures]::MSIXBUNDLE; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.6/PowerShell-7.2.6-win.msixbundle'},
            @{Expected = [AssetArchtectures]::PKG_OSX; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.1.0-preview.3/powershell-6.1.0-preview.3-osx.x64.pkg'},
            @{Expected = [AssetArchtectures]::PKG_OSXARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-rc.1/powershell-7.2.0-rc.1-osx-arm64.pkg'},
            @{Expected = [AssetArchtectures]::PKG_OSX1011; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/powershell-6.0.0-alpha.18-osx.10.11-x64.pkg'},
            @{Expected = [AssetArchtectures]::PKG_OSX1011; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.17/powershell-6.0.0-alpha.17.pkg'},
            @{Expected = [AssetArchtectures]::PKG_OSX1012; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx.10.12-x64.pkg'},
            @{Expected = [AssetArchtectures]::RPM_CM; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.6/powershell-7.2.6-1.cm.x86_64.rpm'},
            @{Expected = [AssetArchtectures]::RPM_CMARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.3/powershell-7.4.3-1.cm.aarch64.rpm'},
            @{Expected = [AssetArchtectures]::RPM_RH; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-preview.5/powershell-preview-7.2.0_preview.5-1.rh.x86_64.rpm'},
            @{Expected = [AssetArchtectures]::RPM_RHEL8; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.2/powershell-7.0.2-1.centos.8.x86_64.rpm'},
            @{Expected = [AssetArchtectures]::RPM_RHEL7; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-1.rhel.7.x86_64.rpm'},
            @{Expected = [AssetArchtectures]::RPM_RHEL7; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.1/powershell-6.0.0_beta.1-1.el7.centos.x86_64.rpm'},
            @{Expected = [AssetArchtectures]::DEB_DEB64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-preview.5/powershell-preview_7.2.0-preview.5-1.deb_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_DEBIAN8; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.debian.8_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_DEBIAN9; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.debian.9_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_DEBIAN10; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/powershell_7.1.0-1.debian.10_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_DEBIAN11; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/powershell_7.1.0-1.debian.11_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_UBUNTU14; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.14.04_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_UBUNTU16; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.16.04_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_UBUNTU17; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_UBUNTU18; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/powershell_7.1.0-1.ubuntu.18.04_amd64.deb'},
            @{Expected = [AssetArchtectures]::DEB_UBUNTU20; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/powershell_7.1.0-1.ubuntu.20.04_amd64.deb'},
            @{Expected = [AssetArchtectures]::APPIMAGE; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-x86_64.AppImage'},
            @{Expected = [AssetArchtectures]::TAR_LINUXARM32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-linux-arm32.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUXARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.2.2/powershell-6.2.2-linux-arm64.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUXALPINE64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.2.2/powershell-6.2.2-linux-alpine-x64.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUX64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-linux-x64.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUX64FXDEPENDENT; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.2.2/powershell-6.2.2-linux-x64-fxdependent.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUXALPINE64FXDEPENDENT; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-x64-musl-noopt-fxdependent.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_LINUXALPINE64FXDEPENDENT; DownloadUrl = ' https://github.com/PowerShell/PowerShell/releases/download/v7.4.0-preview.5/powershell-7.4.0-preview.5-linux-x64-alpine-fxdependent.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_OSX; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-osx-x64.tar.gz'},
            @{Expected = [AssetArchtectures]::TAR_OSXARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-rc.1/powershell-7.2.0-rc.1-osx-arm64.tar.gz'},
            @{Expected = [AssetArchtectures]::ZIP_WINARM32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-arm32.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WINARM64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-arm64.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x86.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WIN32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-x86.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/PowerShell-6.0.0-win-x64.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win10-win2016-x64.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WIN64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/PowerShell-6.0.0-alpha.18-win7-win2008r2-x64.zip'},
            @{Expected = [AssetArchtectures]::ZIP_WINFXDEPENDENT; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.1/PowerShell-7.1.1-win-fxdependent.zip'}
            @{Expected = [AssetArchtectures]::ZIP_WINFXDEPENDENTDESKTOP; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.1/PowerShell-7.1.1-win-fxdependentWinDesktop.zip'}
            @{Expected = [AssetArchtectures]::WIXPDB32; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.3/PowerShell-6.0.3-win-x86.wixpdb'},
            @{Expected = [AssetArchtectures]::WIXPDB64; DownloadUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.3/PowerShell-6.0.3-win-x64.wixpdb'},
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
}