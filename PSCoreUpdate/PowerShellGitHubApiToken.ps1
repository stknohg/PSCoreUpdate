<#
.SYNOPSIS
    [Do not use] Set default GitHub API token
#>
function Set-PowerShellGitHubApiToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Token
    )
    # This feature is removed
    ShowGitHubApitTokenFeatureRemoved
}

<#
.SYNOPSIS
    Remove default GitHub API token
#>
function Remove-PowerShellGitHubApiToken {
    [CmdletBinding()]
    param ()
    # This feature remains for cleaning cofiguration.
    $configFile = GetConfigFilePath
    if (Test-Path $configFile -PathType Leaf) {
        Remove-Item -LiteralPath $configFile -Force
    }
}

<#
.SYNOPSIS
    [Do not use] Display default GitHub API token
#>
function Get-PowerShellGitHubApiToken {
    [CmdletBinding()]
    param ()
    # This feature is removed
    ShowGitHubApitTokenFeatureRemoved
}

function ShowGitHubApitTokenFeatureRemoved () { 
    Write-Host -ForegroundColor Yellow "This feature is removed.`r`nUse SecretManagement module instead."
    $configFile = GetConfigFilePath
    if ( (Test-Path $configFile -PathType Leaf)) {
        Write-Host -ForegroundColor Yellow ("Configuration file {0} still remains`r`nPlease invoke Remove-PowerShellGitHubApiToken to remove configuraion." -f $configFile)
    }
}

function GetConfigFilePath () {
    return Join-Path $HOME ".pscoreupdate"
}
