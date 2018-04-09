# Utility functions, classes.

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
    PKG_OSX1011
    PKG_OSX1012
    RPM_RHEL7
    DEB_DEBIAN8
    DEB_DEBIAN9
    DEB_UBUNTU14
    DEB_UBUNTU16
    DEB_UBUNTU17
    APPIMAGE
    # 
    TAR_LINUXARM32
    TAR_LINUX64
    TAR_OSX
    ZIP_WINARM32
    ZIP_WINARM64
    ZIP_WIN32
    ZIP_WIN64
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
            {$_ -match "^.+win.*-x86.msi$"} {
                return [AssetArchtectures]::MSI_WIN32
            }
            {$_ -match "^.+win.*-x64.msi$"} {
                return [AssetArchtectures]::MSI_WIN64
            }
            {$_ -match "^.+osx.10.11-x64.pkg$"} {
                return [AssetArchtectures]::PKG_OSX1011
            }
            {$_ -match "^.+osx.10.12-x64.pkg$"} {
                return [AssetArchtectures]::PKG_OSX1012
            }
            {$_ -match "^.+.x86_64.rpm$"} {
                return [AssetArchtectures]::RPM_RHEL7
            }
            {$_ -match "^.+debian.8_amd64.deb$"} {
                return [AssetArchtectures]::DEB_DEBIAN8
            }
            {$_ -match "^.+debian.9_amd64.deb$"} {
                return [AssetArchtectures]::DEB_DEBIAN9
            }
            {$_ -match "^.+[ubuntu|ubuntu1].14.\d\d.*_amd64.deb$"} {
                return [AssetArchtectures]::DEB_UBUNTU14
            }
            {$_ -match "^.+[ubuntu|ubuntu1].16.\d\d.*_amd64.deb$"} {
                return [AssetArchtectures]::DEB_UBUNTU16
            }
            {$_ -match "^.+ubuntu.17.\d\d.*_amd64.deb$"} {
                return [AssetArchtectures]::DEB_UBUNTU17
            }
            {$_ -match "^.+.AppImage$"} {
                return [AssetArchtectures]::APPIMAGE
            }
            {$_ -match "^.+linux-arm32.tar.gz$"} {
                return [AssetArchtectures]::TAR_LINUXARM32
            }
            {$_ -match "^.+linux-x64.tar.gz$"} {
                return [AssetArchtectures]::TAR_LINUX64
            }
            {$_ -match "^.+osx-x64.tar.gz$"} {
                return [AssetArchtectures]::TAR_OSX
            }
            {$_ -match "^.+win-arm32.zip$"} {
                return [AssetArchtectures]::ZIP_WINARM32
            }
            {$_ -match "^.+win-arm64.zip$"} {
                return [AssetArchtectures]::ZIP_WINARM64
            }
            {$_ -match "^.+win.*-x86.zip$"} {
                return [AssetArchtectures]::ZIP_WIN32
            }
            {$_ -match "^.+win.*-x64.zip$"} {
                return [AssetArchtectures]::ZIP_WIN64
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
    WriteInfo ('Download {0}' -f $Uri)
    WriteInfo ('  To {0} ...' -f $OutFile)
    if ([string]::IsNullOrEmpty($Token)) {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
    } else {
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Headers @{Authorization = "token $Token"}
    }
}
