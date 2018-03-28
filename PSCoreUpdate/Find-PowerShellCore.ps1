<#
.SYNOPSIS
    Find PowerShell Core releases.
#>
function Find-PowerShellCore {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [SemVer]$MinimamVersion,
        [Parameter(ParameterSetName = 'Latest')]
        [Switch]$Latest
    )
    
    $uri = ''
    switch ($PSCmdlet.ParameterSetName) {
        'Latest' {
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
        }
        Default {
            if ($null -eq $MinimamVersion) {
                $MinimamVersion = $PSVersionTable.PSVersion
            }
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
        }
    }
    $releases = Invoke-RestMethod -Uri $uri
    if (@($releases).Length -eq 0) {
        Write-Warning 'PowerShell Core releases was not found.'
        return
    }
    foreach ($release in $releases) {
        # check version
        $version = $null
        try {
            if ($release.tag_name -match "^v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)($|-(?<Label>.+$))") {
                $version = [SemVer]::new($Matches.Major, $Matches.Minor, $Matches.Patch, $Matches.Label)
            } else {
                Write-Warning ("""{0}"" is not correct version tag name." -f $release.tag_name)
                continue
            }
        } catch {
            continue
        }

        # convert to class
        $obj = [PowerShellCoreRelease]::new()
        $obj.ReleaseId = $release.Id
        $obj.Version = $version
        $obj.Tag = $release.tag_name
        $obj.Name = $release.name
        $obj.Url = $release.url
        $obj.HtmlUrl = $release.html_url
        $obj.PreRelease = $release.prerelease
        $obj.Published = $release.published_at
        $obj.Description = $release.body
        # set assets
        $obj.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
        foreach ($asset in $release.assets) {
            $item = [PowerShellCoreAsset]::new()
            $item.Name = $asset.name
            $item.Url = $asset.url
            $item.Label = $asset.label
            $item.Created = $asset.created_at
            $item.Size = $asset.size
            $item.DownloadUrl = $asset.browser_download_url
            $obj.Assets.Add($item)
        }

        $isOutput = $true
        if ($null -ne $MinimamVersion) {
            if ($obj.version -lt $MinimamVersion) {
                $isOutput = $false
            }
        }
        if ($isOutput) {
            Write-Output $obj
        }
    }
}

