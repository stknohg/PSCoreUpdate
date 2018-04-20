# [WIP] First-time installation scripts

## Windows 

It is necessary to meet [prerequisites](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/windows.md#prerequisites) in advance. 

* Install the [Universal C Runtime](https://www.microsoft.com/download/details.aspx?id=50410) on Windows versions prior to Windows 10.
  It is available via direct download or Windows Update.
  Fully patched (including optional packages), supported systems will already have this installed.
* Install the Windows Management Framework (WMF) [4.0](https://www.microsoft.com/download/details.aspx?id=40855)
  or newer ([5.0](https://www.microsoft.com/download/details.aspx?id=50395),
  [5.1](https://www.microsoft.com/download/details.aspx?id=54616)) on Windows 7.
  
### Command prompt

```dosbatch
REM Command prompt
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/Install-LatestPowerShell.ps1'))"
```

### PowerShell 4.0 - 5.1

```powershell
# Windows PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/Install-LatestPowerShell.ps1'))
```

## macOS

This script supports following versions.

* macOS Sierra (10.12) or higher.

```sh
# Bash
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_mac.sh | bash -s
```

## Linux

### Ubuntu

This script supports following versions.

* Ubuntu 17.04, 16.04, 14.04

```sh
# Bash
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_ubuntu.sh | bash -s
```

### RHEL, CentOS, Fedora

This script supports following versions.

* CentOS 7
* Fedora 26, 25
* RHEL 7

```sh
# Bash
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_rhel.sh | bash -s
```

### Debian

This script supports following versions.

* Debian 9, 8.7+

```sh
# Bash
\wget -q --no-check-certificate https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_debian.sh -O - | bash -s
```

### [Experimental] openSUSE, SLES

This script will support following versions.

* openSUSE 42.1
* SLES 12

```sh
# Bash
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_suse.sh | bash -s
```
