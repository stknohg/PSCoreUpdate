# Utility functions, classes.

class BuildStatus {

    [ReleaseTypes]$Release;
    
    [datetime]$ReleaseDate;

    [string]$BlobName;

    [string]$ReleaseTag;

    [semver]$Version;
}

enum ReleaseTypes {
    Stable = 0
    Preview = 1
    LTS = 2
}

class PowerShellCoreRelease {
    
    [int]$ReleaseId;

    [SemVer]$Version;

    [string]$Tag;

    [string]$Name;

    [uri]$Url;

    [uri]$HtmlUrl;
    
    [bool]$PreRelease;

    [datetime]$Published;

    [string]$Description;

    [System.Collections.Generic.List[PowerShellCoreAsset]]$Assets;
}

enum AssetArchtectures {
    Unknown = 0
    HASHES_SHA256
    MSI_WIN32
    MSI_WIN64
    MSIX_WIN32
    MSIX_WIN64
    MSIX_WINARM32
    MSIX_WINARM64
    PKG_OSX
    PKG_OSXARM64
    PKG_OSX1011
    PKG_OSX1012
    RPM_RH
    RPM_RHEL8
    RPM_RHEL7
    DEB_DEB64
    DEB_DEBIAN8
    DEB_DEBIAN9
    DEB_DEBIAN10
    DEB_DEBIAN11
    DEB_UBUNTU14
    DEB_UBUNTU16
    DEB_UBUNTU17
    DEB_UBUNTU18
    DEB_UBUNTU20
    APPIMAGE
    # 
    TAR_LINUXARM32
    TAR_LINUXARM64
    TAR_LINUXALPINE64
    TAR_LINUX64
    TAR_LINUX64FXDEPENDENT
    TAR_OSX
    TAR_OSXARM64
    ZIP_WINARM32
    ZIP_WINARM64
    ZIP_WIN32
    ZIP_WIN64
    ZIP_WINFXDEPENDENT
    ZIP_WINFXDEPENDENTDESKTOP
    WIXPDB32
    WIXPDB64
}

class PowerShellCoreAsset {

    [string]$Name;

    [uri]$Url;

    [string]$Label;

    [datetime]$Created;

    [long]$Size;

    [uri]$DownloadUrl;

    [AssetArchtectures] GetArchitecture () {
        switch ($this.DownloadUrl.OriginalString.Split("/")[-1]) {
            { $_ -match "^hashes.sha256$" } {
                return [AssetArchtectures]::HASHES_SHA256
            }
            # Note : PowerShell 6 beta MSI file name is OS specific.
            # e.g. PowerShell-6.0.0-beta.6-win10-win2016-x64.msi
            { $_ -match "^.+win.*-x86.msi$" } {
                return [AssetArchtectures]::MSI_WIN32
            }
            { $_ -match "^.+win.*-x64.msi$" } {
                return [AssetArchtectures]::MSI_WIN64
            }
            { $_ -match "^.+win-x86.msix$" } {
                return [AssetArchtectures]::MSIX_WIN32
            }
            { $_ -match "^.+win-x64.msix$" } {
                return [AssetArchtectures]::MSIX_WIN64
            }
            { $_ -match "^.+win-arm32.msix$" } {
                return [AssetArchtectures]::MSIX_WINARM32
            }
            { $_ -match "^.+win-arm64.msix$" } {
                return [AssetArchtectures]::MSIX_WINARM64
            }
            # Note : PKG_OSX, PKG_OSXARM64 is for macOS 10.13 or later
            { $_ -match "^.+osx.x64.pkg$" } {
                return [AssetArchtectures]::PKG_OSX
            }
            { $_ -match "^.+osx.arm64.pkg$" } {
                return [AssetArchtectures]::PKG_OSXARM64
            }
            # Universal rpm packeage 
            { $_ -match "^.+rh.x86_64.rpm$" } {
                return [AssetArchtectures]::RPM_RH
            }
            # Universal deb packeage 
            { $_ -match "^.+deb_amd64.deb$" } {
                return [AssetArchtectures]::DEB_DEB64
            }
            { $_ -match "^.+linux-arm32.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUXARM32
            }
            { $_ -match "^.+linux-arm64.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUXARM64
            }           
            { $_ -match "^.+linux-(musl|alpine)-x64.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUXALPINE64
            }
            { $_ -match "^.+linux-x64.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUX64
            }
            { $_ -match "^.+linux-x64-fxdependent.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUX64FXDEPENDENT
            }
            { $_ -match "^.+osx-x64.tar.gz$" } {
                return [AssetArchtectures]::TAR_OSX
            }
            { $_ -match "^.+osx-arm64.tar.gz$" } {
                return [AssetArchtectures]::TAR_OSXARM64
            }
            { $_ -match "^.+win-arm32.zip$" } {
                return [AssetArchtectures]::ZIP_WINARM32
            }
            { $_ -match "^.+win-arm64.zip$" } {
                return [AssetArchtectures]::ZIP_WINARM64
            }
            { $_ -match "^.+win.*-x86.zip$" } {
                return [AssetArchtectures]::ZIP_WIN32
            }
            { $_ -match "^.+win.*-x64.zip$" } {
                return [AssetArchtectures]::ZIP_WIN64
            }
            { $_ -match "^.+win-fxdependent.zip$" } {
                return [AssetArchtectures]::ZIP_WINFXDEPENDENT
            }
            { $_ -match "^.+win-fxdependentWinDesktop.zip$" } {
                return [AssetArchtectures]::ZIP_WINFXDEPENDENTDESKTOP
            }
            #
            # Postpone checking old version assets
            #
            { $_ -match "^.+win-x86.wixpdb$" } {
                return [AssetArchtectures]::WIXPDB32
            }
            { $_ -match "^.+win-x64.wixpdb$" } {
                return [AssetArchtectures]::WIXPDB64
            }
            { $_ -match "^.+osx.10.11-x64.pkg$" } {
                return [AssetArchtectures]::PKG_OSX1011
            }
            { $_ -match "^.+osx.10.12-x64.pkg$" } {
                return [AssetArchtectures]::PKG_OSX1012
            }
            { $_ -match "^.+(rhel|centos).8.x86_64.rpm$" } {
                return [AssetArchtectures]::RPM_RHEL8
            }
            { $_ -match "^.+(rhel.7.x86_64|el7.centos.x86_64|el7.x86_64|x86_64-centos.7-x64).rpm$" } {
                return [AssetArchtectures]::RPM_RHEL7
            }
            { $_ -match "^.+debian.8_amd64.deb$" } {
                return [AssetArchtectures]::DEB_DEBIAN8
            }
            { $_ -match "^.+debian.9_amd64.deb$" } {
                return [AssetArchtectures]::DEB_DEBIAN9
            }
            { $_ -match "^.+debian.10_amd64.deb$" } {
                return [AssetArchtectures]::DEB_DEBIAN10
            }
            { $_ -match "^.+debian.11_amd64.deb$" } {
                return [AssetArchtectures]::DEB_DEBIAN11
            }
            { $_ -match "^.+(ubuntu|ubuntu1).14.\d\d.*(_amd64|-x64).deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU14
            }
            { $_ -match "^.+(ubuntu|ubuntu1).16.\d\d.*(_amd64|-x64).deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU16
            }
            { $_ -match "^.+ubuntu.17.\d\d.*_amd64.deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU17
            }
            { $_ -match "^.+ubuntu.18.\d\d.*_amd64.deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU18
            }
            { $_ -match "^.+ubuntu.20.\d\d.*_amd64.deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU20
            }
            { $_ -match "^.+.AppImage$" } {
                return [AssetArchtectures]::APPIMAGE
            }
            #
            # for PowerShell 6 beta, alpha versions.
            # I ignore follows intentionally. 
            #  * powershell-6.0.0_beta.*-1.suse.42.1.x86_64.rpm
            #  * powershell-6.0.0_alpha.*-1.suse.42.1.x86_64.rpm
            #  * powershell-6.0.0_alpha.*-1.suse.13.2.x86_64.rpm
            #  * PowerShell_0.6.0.0.appx
            #
            { $_ -match "^PowerShell_6.0.\d.\d.msi$" -or $_ -in ("PowerShell_0.6.0.0.msi", "OpenPowerShell_0.5.0.msi") } {
                return [AssetArchtectures]::MSI_WIN64
            }
            { $_ -match "^powershell-6.0.0-alpha.\d+.pkg$" -or $_ -match "^powershell-0.\d.0.pkg$" } {
                return [AssetArchtectures]::PKG_OSX1011
            }
            { $_ -match "^powershell-0.\d.0-1.x86_64.rpm$" -or $_ -eq "powershell-6.0.0_alpha.7-1.x86_64.rpm" } {
                return [AssetArchtectures]::RPM_RHEL7
            }
            { $_ -match "^powershell_0.\d.0-1_amd64.deb$" -or $_ -eq "powershell_6.0.0-alpha.7-1_amd64.deb" } {
                return [AssetArchtectures]::DEB_UBUNTU14
            }
            Default {
                return [AssetArchtectures]::Unknown
            }
        }
        return [AssetArchtectures]::Unknown
    }
}

function WriteInfo ([string]$message) {
    Write-Host $message -ForegroundColor Green
}

function IsCurrentProcess64bit () {
    return ([System.IntPtr]::Size -eq 8)
}

function IsArmCPU () {
    return ((Get-ComputerInfo -Property OsArchitecture).OsArchitecture -like "ARM*Processor")
}

function DownloadFile ([string]$Uri, [string]$OutFile, [string]$Token) {
    WriteInfo ("Download {0}`r`n  To {1} ..." -f $Uri, $OutFile)
    if ([string]::IsNullOrEmpty($Token)) {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
    } else {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Headers @{ Authorization = "token $Token" }
    }
}
