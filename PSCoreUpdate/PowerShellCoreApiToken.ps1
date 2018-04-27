function GetConfigFilePath () {
    return Join-Path $HOME ".pscoreupdate"
}

function GetCustomSecureKey () {
    # Note :
    #   Currently, ConvertFrom-SecureString is broken on macOS and Linux. (#1654)
    #   We need a custom secure key for a workaround.
    return [byte[]](223, 15, 156, 182, 39, 163, 217, 129, 249, 239, 158, 254, 117, 51, 118, 216, 147, 27, 253, 24, 48, 78, 104, 116)
}

<#
.SYNOPSIS
    Set default GitHub API token
#>
function Set-PowerShellCoreApiToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    $secureToken = ConvertTo-SecureString -String $Token -AsPlainText -Force

    $configFile = GetConfigFilePath
    ConvertTo-Json @{GitHubApiToken = (ConvertFrom-SecureString -SecureString $secureToken -Key (GetCustomSecureKey))} | Out-File -FilePath $configFile -Encoding utf8NoBOM
}

<#
.SYNOPSIS
    Remove default GitHub API token
#>
function Remove-PowerShellCoreApiToken {
    [CmdletBinding()]
    param ()

    $configFile = GetConfigFilePath
    if (Test-Path $configFile -PathType Leaf) {
        Remove-Item -LiteralPath $configFile -Force
    }
}

<#
.SYNOPSIS
    Display default GitHub API token
#>
function Get-PowerShellCoreApiToken {
    [CmdletBinding()]
    param ()
    $token = GetPowerShellCoreApiTokenImpl

    if ([string]::IsNullOrEmpty($token)) {
        Write-Warning 'GitHub API token is not saved.'
        return
    }

    $maskedToken = if ($token.Length -le 5) {
        "*" * ($token.Length)
    } else {
        $token.Substring(0, 5) + "*" * ($token.Length - 5)
    }
    Write-Host ("Saved GitHub API token is : {0}" -f $maskedToken)
}

function GetPowerShellCoreApiTokenImpl () {
    $configFile = GetConfigFilePath
    if (-not (Test-Path $configFile -PathType Leaf)) {
        return ''
    }
    
    $config = Get-Content -LiteralPath $configFile -Encoding utf8NoBOM -Raw | ConvertFrom-Json
    return [System.Net.NetworkCredential]::new('', (ConvertTo-SecureString -String $config.GitHubApiToken -Key (GetCustomSecureKey))).Password
}