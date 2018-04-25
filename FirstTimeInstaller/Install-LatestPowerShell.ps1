#requires -Version 4.0
#
# First-time PowerShell Core installation script for Windows
#

# version and edition check
try {
    if ($PSVersionTable.PSVersion.Major -lt 4) {
        WriteError 'This script supports Windows PowerShell 4.0 or newer.'
        return
    }
    if ($PSVersionTable.PSEdition -eq 'Core') {
        WriteError 'This script supports only Windows PowerShell.'
        return
    }
} catch {
    # do nothing
}

function WriteMessage ([string]$Message) {
    Write-Host $Message -ForegroundColor Green
}

function WriteError ([string]$Message) {
    Write-Host $Message -ForegroundColor Red
}

function GetFileHash ([string]$LiteralPath) {
    if ( -not(Test-Path -LiteralPath $LiteralPath -PathType Leaf) ) {
        return ""
    }
    return (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash
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

# check if the $downloadCache variable exists
if (Test-Path 'Variable:\downloadCache') {
    if (-not $options -is [hashtable]) {
        WriteError '$downloadCache variable should be [Hashtable] type.'
        return
    }
} else {
    $downloadCache = @{}
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
    if ( 
        (Test-Path -LiteralPath $msiOutPath -PathType Leaf) -and 
        (GetFileHash -LiteralPath $msiOutPath) -eq $downloadCache[$msiOutPath]
    ) {
        # use downloaded file
        WriteMessage 'Downloaded MSI file found.'
        WriteMessage ('Use downloaded {0}' -f $msiOutPath)
    } else {
        # download msi
        WriteMessage ('Download {0}' -f $msiUri)
        WriteMessage (' to {0}' -f $msiOutPath)
        Invoke-WebRequest -Uri $msiUri -OutFile $msiOutPath
        # add cache info
        $downloadCache[$msiOutPath] = GetFileHash -LiteralPath $msiOutPath
    }

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

    # checking installation result
    switch ($proc.ExitCode) {
        0 {
            # Success
            break
        }
        3010 {
            # Success required restarting computer
            break
        }
        1602 {
            # User canceled
            Write-Warning "Installation canceled."
            break
        }    
        Default {
            # other errors
            WriteError ("Failed to install.(Exit code={0})" -f $_)
            $errorMessages = Get-Content $msiLogFile | Where-Object { $_ -notmatch "^=== Logging (started:|stopped:).+" }
            foreach ($m in $errorMessages) {
                WriteError $m
            }
            break
        }
    }
}
Install-PowerShellCore -InstallOptions $options
