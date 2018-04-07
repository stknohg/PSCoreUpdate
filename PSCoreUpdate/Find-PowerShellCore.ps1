<#
.SYNOPSIS
    Find PowerShell Core releases.
#>
function Find-PowerShellCore {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [SemVer]$MinimumVersion,
        [Parameter(ParameterSetName = 'Default')]
        [SemVer]$MaximumVersion,
        [Parameter(ParameterSetName = 'Version', Mandatory=$true)]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'Latest')]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Latest')]
        [string]$Token
    )
    
    $uri = ''
    switch ($PSCmdlet.ParameterSetName) {
        'Latest' {
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
        }
        Default {
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
        }
    }
    if ([string]::IsNullOrEmpty($Token)) {
        $releases = Invoke-RestMethod -Uri $uri
    } else {
        $releases = Invoke-RestMethod -Uri $uri -Headers @{Authorization = "token $Token"}
    }
    if (@($releases).Length -eq 0) {
        Write-Warning 'PowerShell Core releases was not found.'
        return
    }
    foreach ($release in $releases) {
        # check version
        $currentVer = $null
        try {
            if ($release.tag_name -match "^v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)($|-(?<Label>.+$))") {
                $currentVer = [SemVer]::new($Matches.Major, $Matches.Minor, $Matches.Patch, $Matches.Label)
            } else {
                Write-Warning ("""{0}"" is not correct version tag name." -f $release.tag_name)
                continue
            }
        } catch {
            continue
        }

        # filter required version
        $isOutput = $true
        switch ($PSCmdlet.ParameterSetName) {
            'Version' {
                if ($currentVer -ne $Version) {
                    $isOutput = $false
                }
            }
            'Default' {
                if ($null -ne $MinimumVersion) {
                    if ($currentVer -lt $MinimumVersion) {
                        $isOutput = $false
                    }
                }
                if ($null -ne $MaximumVersion) {
                    if ($currentVer -gt $MaximumVersion) {
                        $isOutput = $false
                    }
                }
            }
        }
        if (-not $isOutput) {
            continue
        }

        # convert to class
        $obj = [PowerShellCoreRelease]::new()
        $obj.ReleaseId = $release.Id
        $obj.Version = $currentVer
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

        Write-Output $obj
    }
}

