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
    MSI_WIN32
    MSI_WIN64
    PKG_OSX
    PKG_OSX1011
    PKG_OSX1012
    RPM_RHEL7
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
    ZIP_WINARM32
    ZIP_WINARM64
    ZIP_WIN32
    ZIP_WIN64
    ZIP_WINFXDEPENDENT
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
            { $_ -match "^.+win.*-x86.msi$" } {
                return [AssetArchtectures]::MSI_WIN32
            }
            { $_ -match "^.+win.*-x64.msi$" } {
                return [AssetArchtectures]::MSI_WIN64
            }
            { $_ -match "^.+osx.x64.pkg$" } {
                # Note : macOS 10.13 later
                return [AssetArchtectures]::PKG_OSX
            }
            { $_ -match "^.+osx.10.11-x64.pkg$" } {
                return [AssetArchtectures]::PKG_OSX1011
            }
            { $_ -match "^.+osx.10.12-x64.pkg$" } {
                return [AssetArchtectures]::PKG_OSX1012
            }
            { $_ -match "^.+.x86_64.rpm$" } {
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
            { $_ -match "^.+[ubuntu|ubuntu1].14.\d\d.*_amd64.deb$" } {
                return [AssetArchtectures]::DEB_UBUNTU14
            }
            { $_ -match "^.+[ubuntu|ubuntu1].16.\d\d.*_amd64.deb$" } {
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
            { $_ -match "^.+linux-arm32.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUXARM32
            }
            { $_ -match "^.+linux-arm64.tar.gz$" } {
                return [AssetArchtectures]::TAR_LINUXARM64
            }
            { $_ -match "^.+linux-alpine-x64.tar.gz$" } {
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
            { $_ -match "^.+win-x86.wixpdb$" } {
                return [AssetArchtectures]::WIXPDB32
            }
            { $_ -match "^.+win-x64.wixpdb$" } {
                return [AssetArchtectures]::WIXPDB64
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

function DownloadFile ([string]$Uri, [string]$OutFile, [string]$Token) {
    WriteInfo ("Download {0}`r`n  To {1} ..." -f $Uri, $OutFile)
    if ([string]::IsNullOrEmpty($Token)) {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
    } else {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Headers @{ Authorization = "token $Token" }
    }
}
