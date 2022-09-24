# First-time installation scripts

You should use official installation scripts now.

### Windows

* [install-powershell.ps1](https://github.com/PowerShell/PowerShell/blob/master/tools/install-powershell.ps1-README.md)

```powershell
Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -UseMSI -Quiet"
```

### Linux, macOS

* [install-powershell.sh](https://github.com/PowerShell/PowerShell/blob/master/tools/install-powershell.sh-README.md)

```bash
wget -O - https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.sh | sudo bash -s
```

# [Outdated] Previous scripts

__NOTE:__ If you are worried, please inspect each script before doing it for safety.

Each script is based on the official installation instructions.

* [For Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1)
* [For macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7.1)
* [For Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1)

## Windows 

It is necessary to meet [prerequisites](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1#prerequisites) in advance. 

* Install the [Universal C Runtime](https://www.microsoft.com/download/details.aspx?id=50410) on Windows versions prior to Windows 10.
  It is available via direct download or Windows Update.
  Fully patched (including optional packages), supported systems will already have this installed.
  
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

* macOS 10.13+.

```sh
# Bash
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_mac.sh | bash -s
```

## Linux

### Ubuntu

This script supports following versions.

* Ubuntu 20.04, 18.04, 16.04

```sh
# Bash
# Install stable release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_ubuntu.sh | bash -s

# Install preview release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_ubuntu.sh | bash -s preview
```

### RHEL, CentOS, Fedora

This script supports following versions.

* RHEL 8, 7
* CentOS 8, 7
* Fedora 30

```sh
# Bash
# Install stable release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_rhel.sh | bash -s

# Install preview release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_rhel.sh | bash -s preview
```

### Debian

This script supports following versions.

* Debian 10, 9

```sh
# Bash
# Install stable release
\wget -q --no-check-certificate https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_debian.sh -O - | bash -s

# Install preview release
\wget -q --no-check-certificate https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_debian.sh -O - | bash -s preview
```

### [Experimental] openSUSE, SLES

This script will support following versions.

* openSUSE 42.3
* SLES 12

```sh
# Bash
# Install stable release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_suse.sh | bash -s

# Install preview release
\curl -s https://raw.githubusercontent.com/stknohg/PSCoreUpdate/master/FirstTimeInstaller/install_latestpowershell_suse.sh | bash -s preview
```
