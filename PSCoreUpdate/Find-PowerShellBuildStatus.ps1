<#
.SYNOPSIS
    Find latest PowerShell build status
#>
function Find-PowerShellBuildStatus {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [ReleaseTypes]$Release = [ReleaseTypes]::Stable,
        [Parameter(ParameterSetName = 'ShowAll')]
        [switch]$All
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ShowAll' {
            if (-not $All.IsPresent) {
                return
            }
            $items = @()
            foreach ($r in ('Stable', 'Preview', 'LTS')) {
                $items += FindPowerShellBuildStatusImpl -Release $r
            }
            return $items
        }
        Default {
            FindPowerShellBuildStatusImpl -Release $Release
        }
    }
}

function FindPowerShellBuildStatusImpl ([ReleaseTypes]$Release) {
    $buildInfoUri = switch ($Release) {
        'Preview' {
            'https://aka.ms/pwsh-buildinfo-preview'
        }
        'LTS' {
            'https://aka.ms/pwsh-buildinfo-lts'
        }
        Default {
            # Stable is default
            'https://aka.ms/pwsh-buildinfo-stable'
        }
    }
    $response = Invoke-RestMethod -Uri $buildInfoUri
    $result = [BuildStatus]::New()
    $result.Release = $Release
    $result.ReleaseDate = $response.ReleaseDate
    $result.BlobName = $response.BlobName
    $result.ReleaseTag = $response.ReleaseTag
    # note : https://github.com/PowerShell/PowerShell/blob/v7.0.3/src/Microsoft.PowerShell.ConsoleHost/host/msh/UpdatesNotification.cs#L376
    $result.Version = [semver]($response.ReleaseTag.Substring(1))
    return $result
}