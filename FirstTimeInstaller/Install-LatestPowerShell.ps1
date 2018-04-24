#requires -Version 4.0
#
# First-time PowerShell Core installation script for Windows
#

function WriteMessage ([string]$Message) {
    Write-Host $Message -ForegroundColor Green
}

function WriteError ([string]$Message) {
    Write-Host $Message -ForegroundColor Red
}

# edition check
try {
    if ($PSVersionTable.PSEdition -eq 'Core') {
        WriteError 'This script supports only Windows PowerShell.'
        return
    }
} catch {
    # do nothing
}

# check if the $options variable exists
# Note : 
#   $options variable accepts MSI installer arguments.
#   Currently following parameters are allowed.
#     INSTALLFOLDER = "C:\PowerShell\" : Install folder
#     REGISTER_MANIFEST = [0|1] : Register Windows Event Logging Manifest
#     ENABLE_PSREMOTING = [0|1] : Enable PowerShell remoting
#     ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL = [0|1] : Add 'Open here' context menus to Explorer
# Example :
#   $options = @{INSTALLFOLDER = "C:\PowerShell\"}
if (Test-Path 'Variable:\options') {
    if (-not $options -is [hashtable]) {
        WriteError '$options variable should be [Hashtable] type.'
        return
    }
} else {
    $options = $null
}

# install PowerShell Core
function Install-PowerShellCore ([hashtable]$InstallOptions) {
    # find release
    WriteMessage 'Find Latest PowerShell Core release...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    if ($null -eq $release) {
        WriteError 'Failed to get the latest PowerShell Core release.'
        return
    }

    # find MSI url
    $msiUri = if ([System.IntPtr]::Size -eq 8) {
        $release.Assets | Where-Object { $_.browser_download_url -match '^.+win-x64.msi$' } | Select-Object -ExpandProperty browser_download_url
    } else {
        $release.Assets | Where-Object { $_.browser_download_url -match '^.+win-x86.msi$' } | Select-Object -ExpandProperty browser_download_url
    }
    if ($null -eq $msiUri) {
        WriteError 'Failed to get the latest PowerShell Core MSI url.'
        return
    }
    if (@($msiUri).Length -gt 1) {
        WriteError 'Failed to get a single PowerShell Core MSI url.'
        foreach ($i in $msiUri) {
            WriteError ('  Url : {0}' -f $i)
        }
        return
    }

    # download MSI
    $msiOutPath = Join-Path -Path ([IO.Path]::GetTempPath()) ($msiUri -split '/')[-1]
    WriteMessage ('Download {0}' -f $msiUri)
    WriteMessage (' to {0}' -f $msiOutPath)
    Invoke-WebRequest -Uri $msiUri -OutFile $msiOutPath

    # silent install
    $msiLogFile = Join-Path -Path ([IO.Path]::GetTempPath()) ("{0}.log" -f [IO.Path]::GetFileNameWithoutExtension($msiOutPath))
    $args = @('/i', $msiOutPath, '/passive', '/le', $msiLogFile)
    if ($null -ne $InstallOptions) {
        foreach ($key in $InstallOptions.Keys) {
            $args += ('{0}={1}' -f $key, $InstallOptions[$key])
        }
    }
    WriteMessage 'Install PowerShell Core...'
    WriteMessage ('msiexec.exe {0}' -f ($args -join ' '))
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $args -Wait -PassThru

    # checking installation result(.log)
    if ($proc.ExitCode -ne 0) {
        WriteError "Failed to install."
        $errorMessages = Get-Content $msiLogFile | Where-Object { $_ -notmatch "^=== Logging (started:|stopped:).+" }
        foreach ($m in $errorMessages) {
            WriteError $m
        }
    }
}
Install-PowerShellCore -InstallOptions $options
