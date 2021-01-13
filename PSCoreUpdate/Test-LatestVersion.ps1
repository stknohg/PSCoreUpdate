<#
.SYNOPSIS
    Test current PowerShell Core is the latest version.
#>
function Test-LatestVersion {
    [CmdletBinding()]
    param (
        [ReleaseTypes]$Release = [ReleaseTypes]::Stable,
        [switch]$PassThru
    )

    # get latest build status
    $buildStatus = Find-PowerShellBuildStatus -Release $Release
    if (-not $buildStatus) {
        Write-Error $Messages.Test_LatestVersion_001
        return
    }

    if ($PSVersionTable.PSVersion -gt $buildStatus.Version) {
        # Note : This pattern occurs when using LTS, Preview version.
        WriteInfo ($Messages.Test_LatestVersion_002 -f $PSVersionTable.PSVersion, $buildStatus.Version)
        NotifyNewVersion -Published $buildStatus.ReleaseDate -Release $Release
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $Release; LatestVersion = $buildStatus.Version }
        }
        return
    }
    if ($PSVersionTable.PSVersion -eq $buildStatus.Version) {
        WriteInfo ($Messages.Test_LatestVersion_003 -f $PSVersionTable.PSVersion)
        NotifyNewVersion -Published $buildStatus.ReleaseDate -Release $Release
        if ($PassThru) {
            return [PSCustomObject]@{ Result = $true; Release = $Release; LatestVersion = $buildStatus.Version }
        }
        return
    }
    Write-Warning ($Messages.Test_LatestVersion_004 -f $buildStatus.Version)
    if ($PassThru) {
        return [PSCustomObject]@{ Result = $false; Release = $Release; LatestVersion = $buildStatus.Version }
    }
}

function NotifyNewVersion ([datetime]$Published, [ReleaseTypes]$Release) {
    # Note : Notify the new version releasing is coming.
    #  * Stable Release : after a half year (180 days)
    #  * Preview Release : after 3 weeks (21 days)
    #  * LTS : no notification
    if ($Release -eq 'LTS') {
        return
    }
    $span = if ($Release -eq 'Preview') {[timespan]::new(21, 0, 0, 0)} else {[timespan]::new(180, 0, 0, 0)}
    $elapsed = (Get-Date).Subtract($Published)
    if ($elapsed -ge $span) {
        WriteInfo ""
        WriteInfo ($Messages.Test_LatestVersion_005 -f $elapsed.Days)
        WriteInfo $Messages.Test_LatestVersion_006
    }
}