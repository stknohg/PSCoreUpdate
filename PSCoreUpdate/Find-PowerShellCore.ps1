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
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'Latest')]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Latest')]
        [Switch]$ExcludePreRelease,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Latest')]
        [string]$Token
    )
    
    $uri = ''
    switch ($PSCmdlet.ParameterSetName) {
        'Latest' {
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
            if ($ExcludePreRelease) {
                $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
            }
        }
        Default {
            $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
        }
    }
    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellCoreApiTokenImpl
    }
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $releaseSets = Invoke-RestMethod -Uri $uri -FollowRelLink
    } else {
        $releaseSets = Invoke-RestMethod -Uri $uri -FollowRelLink -Headers @{Authorization = "token $specifiedToken"}
    }
    if (@($releaseSets).Length -eq 0) {
        Write-Warning $Messages.Find_PowerShellCore_001
        return
    }
    if ($releaseSets -is [Object[]]) {
        # when $releaseSets contains some links.
        foreach ($releases in $releaseSets) {
            GetPowerShellCoreRelease -Releases $releases -Version $Version -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion
        }
    } elseif ($releaseSets -is [PSCustomObject]) {
        # when $releaseSets has no link.
        GetPowerShellCoreRelease -Releases $releaseSets -Version $Version -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion
    }
}

function GetPowerShellCoreRelease ([PSCustomObject]$Releases, [SemVer]$Version, [SemVer]$MinimumVersion, [SemVer]$MaximumVersion) {
    $outputObjects = [System.Collections.Generic.List[PowerShellCoreRelease]]::new()
    foreach ($release in $Releases) {
        # check version
        $currentVer = $null
        try {
            if ($release.tag_name -match "^v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)($|-(?<Label>.+$))") {
                $currentVer = [SemVer]::new($Matches.Major, $Matches.Minor, $Matches.Patch, $Matches.Label)
            } else {
                Write-Warning ($Messages.Find_PowerShellCore_002 -f $release.tag_name)
                continue
            }
        } catch {
            continue
        }

        # is prerelease
        $isPreRelease = $release.prerelease -or (-not [string]::IsNullOrEmpty($currentVer.PreReleaseLabel)) -or $currentVer.Major -lt 6

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
        if ($ExcludePreRelease) {
            if ($isPreRelease) {
                $isOutput = $false
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
        $obj.PreRelease = $isPreRelease
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
        $outputObjects.Add($obj)
    }
    
    # output
    if ($Latest) {
        $outputObjects | Sort-Object -Top 1 -Property Version -Descending
    } else {
        foreach ($o in $outputObjects) {
            Write-Output $o
        }
    }
}