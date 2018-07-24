<#
.SYNOPSIS
    Test current PowerShell Core is the latest version.
#>
function Test-LatestVersion {
    [CmdletBinding()]
    param (
        [Switch]$IncludePreRelease = $false,
        [string]$Token,
        [switch]$PassThru
    )

    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellCoreApiTokenImpl
    }
    $release = Find-PowerShellCore -Latest -Token $specifiedToken -IncludePreRelease:$IncludePreRelease
    if ($null -eq $release) {
        Write-Error $Messages.Test_LatestVersion_001
        return
    }

    if ($PSVersionTable.PSVersion -gt $release.Version) {
        # Note : This pattern occurs when using -IncludePreRelease parameter.
        WriteInfo ($Messages.Test_LatestVersion_002 -f $PSVersionTable.PSVersion, $release.Version)
        NotifyNewVersion -Published $release.Published -IncludePreRelease $IncludePreRelease
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $release }
        }
        return
    }
    if ($PSVersionTable.PSVersion -eq $release.Version) {
        WriteInfo ($Messages.Test_LatestVersion_003 -f $PSVersionTable.PSVersion)
        NotifyNewVersion -Published $release.Published -IncludePreRelease $IncludePreRelease
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $release }
        }
        return
    }
    Write-Warning ($Messages.Test_LatestVersion_004 -f $release.Version)
    if ($PassThru) {
        return [PSCustomObject]@{ Result = $false; Release = $release }
    }
}

function NotifyNewVersion ([datetime]$Published, [boolean]$IncludePreRelease) {
    # Note : Notify the new version releasing is coming.
    #  * Stable Release : after a half year (180 days)
    #  * PreRelease : after 3 weeks (21 days)
    $span = if ($IncludePreRelease) {[timespan]::new(21, 0, 0, 0)} else {[timespan]::new(180, 0, 0, 0)}
    $elapsed = (Get-Date).Subtract($Published)
    if ($elapsed -ge $span) {
        WriteInfo ""
        WriteInfo ($Messages.Test_LatestVersion_005 -f $elapsed.Days)
        WriteInfo $Messages.Test_LatestVersion_006
    }
}