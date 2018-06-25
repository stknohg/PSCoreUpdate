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
No updates. PowerShell Core 6.1.0-preview.2 is the latest version.
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

If you want to install the stable release only, you can use `-ExcludePreRelease` parameter.

```powershell
PS C:\> Update-PowerShellCore -Latest -ExcludePreRelease
```

### Find-PowerShellCore

Find PowerShell Core release information from GitHub.

```powershell
PS C:\> Find-PowerShellCore -MinimumVersion 6.0.0

Version         Name                                        Published           PreRelease
-------         ----                                        ---------           ----------
6.1.0-preview.2 v6.1.0-preview.2 Release of PowerShell Core 2018/04/27 20:28:09 True
6.1.0-preview.1 v6.1.0-preview.1 Release of PowerShell Core 2018/03/24 1:21:41  True
6.0.2           v6.0.2 release of PowerShell Core           2018/03/15 18:00:46 False
6.0.1           v6.0.1 release of PowerShell Core           2018/01/25 22:14:29 False
6.0.0           v6.0.0 release of PowerShell Core           2018/01/20 0:19:22  False
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
|PKG_OSX1011|[PowerShell version]-osx.10.11-x64.pkg|
|PKG_OSX1012|[PowerShell version]-osx.10.12-x64.pkg|
|RPM_RHEL7|[PowerShell version]-rhel.7.x86_64.rpm|
|DEB_DEBIAN8|[PowerShell version]-debian.8_amd64.deb|
|DEB_DEBIAN9|[PowerShell version]-debian.9_amd64.deb|
|DEB_UBUNTU14|[PowerShell version]-ubuntu.14.nn_amd64.deb|
|DEB_UBUNTU16|[PowerShell version]-ubuntu.16.nn_amd64.deb|
|DEB_UBUNTU17|[PowerShell version]-ubuntu.17.nn_amd64.deb|
|APPIMAGE|[PowerShell version]-x86_64.AppImage|
|TAR_LINUXARM32|[PowerShell version]-linux-arm32.tar.gz|
|TAR_LINUX64|[PowerShell version]-linux-x64.tar.gz|
|TAR_OSX|[PowerShell version]-osx-x64.tar.gz|
|ZIP_WINARM32|[PowerShell version]-win-arm32.zip|
|ZIP_WINARM64|[PowerShell version]-win-arm64.zip|
|ZIP_WIN32|[PowerShell version]-win-x86.zip|
|ZIP_WIN64|[PowerShell version]-win-x64.zip|
