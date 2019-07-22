# PSCoreUpdate

[![Build status](https://ci.appveyor.com/api/projects/status/pewb2qx34quqleu5?svg=true)](https://ci.appveyor.com/project/stknohg/pscoreupdate)

PowerShell Core update tool.

## Motivation

PSCoreUpdate supports automation update of PowerShell Core.  

Currently, PowerShell Team is planning on supporting security updates of PowerShell Core through Microsoft Update on Windows ([#6118](https://github.com/PowerShell/PowerShell/issues/6118)), but it will take some time for realization.  
[Homebrew Cask](https://caskroom.github.io/) is now available on macOS, but the installation of Homebrew is a bit heavy.  

This module is a little tool to solve such inconvenience.

## How to install

You can install it from [PowerShell gallery](https://www.powershellgallery.com/packages/PSCoreUpdate).

```powershell
Install-Module PSCoreUpdate -Scope CurrentUser
```

### First-time installation scripts

This module is for updating PowerShell Core.  
So, the first-time installation must be performed manually.

We prepared the following page to facilitate the first-time installation.

* [First-time installation scripts](./FirstTimeInstaller/)

## Usage

### Test-LatestVersion

Check if the current console is the latest version.

```powershell
PS C:\> Test-LatestVersion
No updates. PowerShell 6.2.2 is the latest version.
```

### Update-PowerShellCore

Update PowerShell Core if the newer version found.   

```powershell
PS C:\> Update-PowerShellCore -Latest
```

<img src="https://user-images.githubusercontent.com/720127/38464437-dfe8b956-3b48-11e8-8c39-8f76102a9073.gif" width="800">

You can do silent install with `-Silent` switch parameter.

```powershell
PS C:\> Update-PowerShellCore -Latest -Silent
```

* This cmdlet supports only Windows and macOS.  
  You can use a package management tool like yum, apt etc. on Linux.

If you want to install the preview release, you can use `-IncludePreRelease` parameter.

```powershell
PS C:\> Update-PowerShellCore -Latest -IncludePreRelease
```

### Find-PowerShellCore

Find PowerShell Core release information from GitHub.

```powershell
PS C:\> Find-PowerShellCore

Version Name                              Published           PreRelease
------- ----                              ---------           ----------
6.2.2   v6.2.2 Release of PowerShell Core 2019/07/16 17:22:31 False
6.1.5   v6.1.5 Release of PowerShell Core 2019/07/16 17:17:29 False
6.2.1   v6.2.1 Release of PowerShell Core 2019/05/21 17:58:45 False
6.1.4   v6.1.4 Release of PowerShell Core 2019/05/21 17:58:26 False
6.2.0   v6.2.0 Release of PowerShell Core 2019/03/28 18:42:02 False
6.1.3   v6.1.3 Release of PowerShell Core 2019/02/19 18:29:23 False
6.1.2   v6.1.2 Release of PowerShell Core 2019/01/15 20:02:39 False
6.1.1   v6.1.1 Release of PowerShell Core 2018/11/13 18:00:39 False
6.0.5   v6.0.5 Release of PowerShell Core 2018/11/13 18:00:56 False
6.1.0   v6.1.0 Release of PowerShell Core 2018/09/13 21:49:59 False
6.0.4   v6.0.4 Release of PowerShell Core 2018/08/10 22:20:50 False
6.0.3   v6.0.3 Release of PowerShell Core 2018/07/20 17:42:19 False
6.0.2   v6.0.2 release of PowerShell Core 2018/03/15 18:00:46 False
6.0.1   v6.0.1 release of PowerShell Core 2018/01/25 22:14:29 False
6.0.0   v6.0.0 release of PowerShell Core 2018/01/20 0:19:22  False
```

### Save-PowerShellCore

Download PowerShell Core release assets.

```powershell
PS C:\> Save-PowerShellCore -Latest -AssetType MSI_WIN32 -OutDirectory .\
```

The types of assets are as follows.

|Value|Asset|
|----|----|
|MSI_WIN32|[PowerShell version]-win-x86.msi|
|MSI_WIN64|[PowerShell version]-win-x64.msi|
|PKG_OSX|[PowerShell version]-osx-x64.pkg|
|RPM_RHEL7|[PowerShell version]-rhel.7.x86_64.rpm|
|DEB_DEBIAN9|[PowerShell version]-debian.9_amd64.deb|
|DEB_UBUNTU16|[PowerShell version]-ubuntu.16.nn_amd64.deb|
|DEB_UBUNTU18|[PowerShell version]-ubuntu.17.nn_amd64.deb|
|TAR_LINUXARM32|[PowerShell version]-linux-arm32.tar.gz|
|TAR_LINUXARM64|[PowerShell version]-linux-arm64.tar.gz|
|TAR_LINUXALPINE64|[PowerShell version]-linux-alpine-x64.tar.gz|
|TAR_LINUX64FXDEPENDENT|[PowerShell version]-linux-x64-fxdependent.tar.gz|
|TAR_LINUX64|[PowerShell version]-linux-x64.tar.gz|
|TAR_OSX|[PowerShell version]-osx-x64.tar.gz|
|ZIP_WINARM32|[PowerShell version]-win-arm32.zip|
|ZIP_WINARM64|[PowerShell version]-win-arm64.zip|
|ZIP_WIN32|[PowerShell version]-win-x86.zip|
|ZIP_WIN64|[PowerShell version]-win-x64.zip|
|ZIP_WINFXDEPENDENT|[PowerShell version]-win-fxdependent.zip|
|WIXPDB32|[PowerShell version]-win-x86.wixpdb|
|WIXPDB64|[PowerShell version]-win-x64.wixpdb|

#### Old release assets

* These assets are not available from the latest version.

|Value|Asset|
|----|----|
|PKG_OSX1011|[PowerShell version]-osx.10.11-x64.pkg|
|PKG_OSX1012|[PowerShell version]-osx.10.12-x64.pkg|
|DEB_DEBIAN8|[PowerShell version]-debian.8_amd64.deb|
|DEB_UBUNTU14|[PowerShell version]-ubuntu.14.nn_amd64.deb|
|DEB_UBUNTU17|[PowerShell version]-ubuntu.17.nn_amd64.deb|
|APPIMAGE|[PowerShell version]-x86_64.AppImage|