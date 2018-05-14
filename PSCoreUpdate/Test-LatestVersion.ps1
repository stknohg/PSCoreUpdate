<#
.SYNOPSIS
    Test current PowerShell Core is the latest version.
#>
function Test-LatestVersion {
    [CmdletBinding()]
    param (
        [Switch]$ExcludePreRelease,
        [string]$Token,
        [switch]$PassThru
    )

    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellCoreApiTokenImpl
    }
    $release = Find-PowerShellCore -Latest -Token $specifiedToken -ExcludePreRelease:$ExcludePreRelease
    if ($null -eq $release) {
        Write-Error 'Failed to get the latest version.'
        return
    }

    if ($PSVersionTable.PSVersion -gt $release.Version) {
        # Note : This pattern occurs when using -ExcludePreRelease parameter.
        WriteInfo ('PowerShell Core {0} is newer than the latest version {1}.' -f $PSVersionTable.PSVersion, $release.Version)
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $release }
        }
        return
    }
    if ($PSVersionTable.PSVersion -eq $release.Version) {
        WriteInfo ('No updates. PowerShell Core {0} is the latest version.' -f $PSVersionTable.PSVersion)
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $release }
        }
        return
    }
    Write-Warning ('Newer version PowerShell Core {0} is available.' -f $release.Version)
    if ($PassThru) {
        return [PSCustomObject]@{ Result = $false; Release = $release }
    }
}