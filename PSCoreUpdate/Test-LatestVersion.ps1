<#
.SYNOPSIS
    Test current PowerShell Core is the latest version.
#>
function Test-LatestVersion {
    [CmdletBinding()]
    param (
        [string]$Token,
        [switch]$PassThru
    )

    $release = Find-PowerShellCore -Latest -Token $Token
    if ($null -eq $release) {
        Write-Error 'Failed to get the latest version.'
        return
    }

    if ($PSVersionTable.PSVersion -ge $release.Version) {
        WriteInfo ('No updates. PowerShell Core {0} is the latest version.' -f $PSVersionTable.PSVersion)
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $null }
        }
        return
    }
    Write-Warning ('Newer version PowerShell Core {0} is available.' -f $release.Version)
    if ($PassThru) {
        return [PSCustomObject]@{ Result = $false; Release = $release }
    }
}