# PSCoreUpdate

![build](https://github.com/stknohg/PSCoreUpdate/workflows/build/badge.svg)

New cross-platform PowerShell update tool.

## Motivation

PSCoreUpdate supports automation update of new cross-platform PowerShell (pwsh).  

<del>Currently, PowerShell Team is planning on supporting security updates of PowerShell through Microsoft Update on Windows ([#6118](https://github.com/PowerShell/PowerShell/issues/6118)), but it will take some time for realization.  
[Homebrew Cask](https://caskroom.github.io/) is now available on macOS, but the installation of Homebrew is a bit heavy.</del>

PowerShell Team began supporting updates to PowerShell via Microsoft Update starting with PowerShell 7.2, but updates cannot be performed at any time, and there is no module that can manage release assets.

This module is a little tool to solve such inconvenience.

## How to install

You can install it from [PowerShell gallery](https://www.powershellgallery.com/packages/PSCoreUpdate).

```powershell
# Using PowerShellGet
Install-Module PSCoreUpdate

# Using Microsoft.PowerShell.PSResourceGet
Install-PSResource -Name PSCoreUpdate
```

### Upgrade from version 2

If you use PSCoreUpdate version 2 or earlier, please uninstall all version first.

```powershell
Uninstall-Module PSCoreUpdate -AllVersions
Install-Module PSCoreUpdate
```

Note : PSCoreUpdate version.3 has many breaking changes.

* See the [release note](https://github.com/stknohg/PSCoreUpdate/releases/tag/v3.0.0) for detail.

### First-time installation

This module is for updating PowerShell.  
So, the first-time installation must be performed manually.

You can use the [official installation script](https://github.com/PowerShell/PowerShell/blob/master/tools/install-powershell.ps1-README.md).

```powershell
Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -UseMSI -Quiet"
```

## Usage

### Test-LatestVersion

Check if the current console is the latest version.

```powershell
PS C:\> Test-LatestVersion
No updates. PowerShell 7.4.3 is the latest version.
```

If you use preview release PowerShell, you can use `-Release Preview` parameter.

```powershell
PS C:\> Test-LatestVersion -Release Preview
```

if you use LTS version PowerShell, you can can use `-Release LTS` parameter.

```powershell
PS C:\> Test-LatestVersion -Release LTS
```

### Update-PowerShellRelease

Update PowerShell if the newer version found.   

```powershell
PS C:\> Update-PowerShellRelease -Latest
```

![Update-PowerShellRelease.gif](./assets/Update-PowerShellRelease.gif)

If you want to update preview release, you can use `-Release Preview` parameter.

```powershell
PS C:\> Update-PowerShellRelease -Latest -Release Preview
```

if you use LTS version PowerShell, you can can use `-Release LTS` parameter.

```powershell
PS C:\> Update-PowerShellRelease -Latest -Release LTS
```

You can do silent install with `-Silent` switch parameter.

```powershell
PS C:\> Update-PowerShellRelease -Latest -Silent
```

* This cmdlet supports only Windows and macOS.  
  You can use a package management tool like yum, apt etc. on Linux.

### Find-PowerShellRelease

Find PowerShell release information from GitHub.

```powershell
PS C:\> Find-PowerShellRelease -MaxItems 10

Version Name                          Published           PreRelease
------- ----                          ---------           ----------
7.4.3   v7.4.3 Release of PowerShell  2024/06/18 23:13:56 False
7.4.2   v7.4.2 Release of PowerShell  2024/04/11 23:07:12 False
7.4.1   v7.4.1 Release of PowerShell  2024/01/11 23:08:30 False
7.4.0   v7.4.0 Release of PowerShell  2023/11/16 17:06:48 False
7.3.12  v7.3.12 Release of PowerShell 2024/04/11 22:57:39 False
7.3.11  v7.3.11 Release of PowerShell 2024/01/11 22:01:05 False
7.3.10  v7.3.10 Release of PowerShell 2023/11/16 17:05:59 False
7.3.9   v7.3.9 Release of PowerShell  2023/10/26 17:57:23 False
7.3.8   v7.3.8 Release of PowerShell  2023/10/10 17:15:04 False
7.3.7   v7.3.7 Release of PowerShell  2023/09/19 16:28:10 False
```

#### New features from version.3

`Find-PowerShellRelease` stores local in-memory cache for 10 minutes.  
If you don't want use cache, use `-NoCache` parameter.

```powershell
Find-PowerShellRelease -MaxItems 10 -NoCache
```

`-VersionRange` parameter is added instead of `-MinimumVersion`, `-MaximumVersion`.  
This parameter follows [Nuget version range](https://docs.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges) syntax.

```powershell
PS C:\> Find-PowerShellRelease -VersionRange "[7.3,7.4]"

Version Name                          Published           PreRelease
------- ----                          ---------           ----------
7.4.0   v7.4.0 Release of PowerShell  2023/11/16 17:06:48 False
7.3.12  v7.3.12 Release of PowerShell 2024/04/11 22:57:39 False
7.3.11  v7.3.11 Release of PowerShell 2024/01/11 22:01:05 False
7.3.10  v7.3.10 Release of PowerShell 2023/11/16 17:05:59 False
7.3.9   v7.3.9 Release of PowerShell  2023/10/26 17:57:23 False
7.3.8   v7.3.8 Release of PowerShell  2023/10/10 17:15:04 False
7.3.7   v7.3.7 Release of PowerShell  2023/09/19 16:28:10 False
7.3.6   v7.3.6 Release of PowerShell  2023/07/13 22:39:48 False
7.3.5   v7.3.5 Release of PowerShell  2023/06/27 23:21:50 False
7.3.4   v7.3.4 Release of PowerShell  2023/04/13 18:37:36 False
7.3.3   v7.3.3 Release of PowerShell  2023/02/24 1:22:55  False
7.3.2   v7.3.2 Release of PowerShell  2023/01/24 19:34:31 False
7.3.1   v7.3.1 Release of PowerShell  2022/12/13 16:17:08 False
7.3.0   v7.3.0 Release of PowerShell  2022/11/09 0:37:40  False
```

### Find-PowerShellBuildStatus

Find PowerShell build status.

```powershell
PS C:\> Find-PowerShellBuildStatus -All

Version         Release ReleaseDate
-------         ------- -----------
7.4.3           Stable  2024/06/18 23:26:06
7.5.0-preview.3 Preview 2024/05/28 18:13:56
7.4.3           LTS     2024/06/18 23:26:06
```

### Save-PowerShellAsset

Download PowerShell release assets.

```powershell
PS C:\> Save-PowerShellAsset -Latest -AssetType MSI_WIN64 -OutDirectory .\
```

The types of assets are as follows.

|Value|Asset|
|----|----|
|HASHES_SHA256|hashes.sha256|
|MSI_WIN32|[PowerShell version]-win-x86.msi|
|MSI_WIN64|[PowerShell version]-win-x64.msi|
|MSI_ARM64|[PowerShell version]-win-arm64.msi|
|MSIXBUNDLE|[PowerShell version]-win.msixbundle|
|PKG_OSX|[PowerShell version]-osx-x64.pkg|
|PKG_OSXARM64|[PowerShell version]-osx-arm64.pkg|
|RPM_CM|[PowerShell version]-cm.x86_64.rpm|
|RPM_CMARM64|[PowerShell version]-cm.aarch64.rpm|
|RPM_RH|[PowerShell version]-rh.x86_64.rpm|
|DEB_DEB64|[PowerShell version]-deb_amd64.deb|
|TAR_LINUXARM32|[PowerShell version]-linux-arm32.tar.gz|
|TAR_LINUXARM64|[PowerShell version]-linux-arm64.tar.gz|
|TAR_LINUXALPINE64|[PowerShell version]-linux-(musl\|alpine)-x64.tar.gz|
|TAR_LINUX64FXDEPENDENT|[PowerShell version]-linux-x64-fxdependent.tar.gz|
|TAR_LINUXALPINE64FXDEPENDENT|[PowerShell version]-x64-(musl-noopt\|alpine)-fxdependent.tar.gz|
|TAR_LINUX64|[PowerShell version]-linux-x64.tar.gz|
|TAR_OSX|[PowerShell version]-osx-x64.tar.gz|
|TAR_OSXARM64|[PowerShell version]-osx-arm64.tar.gz|
|ZIP_WINARM32|[PowerShell version]-win-arm32.zip|
|ZIP_WINARM64|[PowerShell version]-win-arm64.zip|
|ZIP_WIN32|[PowerShell version]-win-x86.zip|
|ZIP_WIN64|[PowerShell version]-win-x64.zip|
|ZIP_WINFXDEPENDENT|[PowerShell version]-win-fxdependent.zip|
|ZIP_WINFXDEPENDENTDESKTOP|[PowerShell version]-win-fxdependentWinDesktop.zip|

#### Old release assets

* These assets are not available from the latest version.

|Value|Asset|
|----|----|
|MSIX_WIN32|[PowerShell version]-win-x86.msix (Currently unreleased [#13284](https://github.com/PowerShell/PowerShell/issues/13284))|
|MSIX_WIN64|[PowerShell version]-win-x64.msix (Currently unreleased [#13284](https://github.com/PowerShell/PowerShell/issues/13284))|
|MSIX_WINARM32|[PowerShell version]-win-arm32.msix (Currently unreleased [#13284](https://github.com/PowerShell/PowerShell/issues/13284))|
|MSIX_WINARM64|[PowerShell version]-win-arm64.msix (Currently unreleased [#13284](https://github.com/PowerShell/PowerShell/issues/13284))|
|PKG_OSX1011|[PowerShell version]-osx.10.11-x64.pkg|
|PKG_OSX1012|[PowerShell version]-osx.10.12-x64.pkg|
|RPM_RHEL8|[PowerShell version]-centos.8.x86_64.rpm|
|RPM_RHEL7|[PowerShell version]-rhel.7.x86_64.rpm|
|DEB_DEBIAN8|[PowerShell version]-debian.8_amd64.deb|
|DEB_DEBIAN9|[PowerShell version]-debian.9_amd64.deb|
|DEB_DEBIAN10|[PowerShell version]-debian.10_amd64.deb|
|DEB_DEBIAN11|[PowerShell version]-debian.11_amd64.deb|
|DEB_UBUNTU14|[PowerShell version]-ubuntu.14.nn_amd64.deb|
|DEB_UBUNTU16|[PowerShell version]-ubuntu.16.nn_amd64.deb|
|DEB_UBUNTU17|[PowerShell version]-ubuntu.17.nn_amd64.deb|
|DEB_UBUNTU18|[PowerShell version]-ubuntu.18.nn_amd64.deb|
|DEB_UBUNTU20|[PowerShell version]-ubuntu.20.nn_amd64.deb|
|APPIMAGE|[PowerShell version]-x86_64.AppImage|
|WIXPDB32|[PowerShell version]-win-x86.wixpdb|
|WIXPDB64|[PowerShell version]-win-x64.wixpdb|
