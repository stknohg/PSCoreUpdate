<#
.SYNOPSIS
    Find PowerShell releases.
#>
function Find-PowerShellRelease {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [SemVer]$MinimumVersion,
        [Parameter(ParameterSetName = 'Default')]
        [SemVer]$MaximumVersion,
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'VersionTag', Mandatory = $true)]
        [string]$VersionTag,
        [Parameter(ParameterSetName = 'Latest', Mandatory = $true)]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Latest')]
        [ReleaseTypes]$Release = [ReleaseTypes]::Stable,
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$IncludePreRelease = $false,
        [Parameter(ParameterSetName = 'Default')]
        [int]$MaxItems = [int]::MaxValue,
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$AsStream,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'VersionTag')]
        [Parameter(ParameterSetName = 'Latest')]
        [string]$Token
    )
    begin {
        # validate parameters
        $_AbortProcess = $false
        switch ($PSCmdlet.ParameterSetName) {
            'VersionTag' {
                if ( -not (GetVersionFromTag -VersionTag $VersionTag) ) {
                    Write-Error ($Messages.Find_PowerShellRelease_002 -f $VersionTag)
                    $_AbortProcess = $true
                    return
                }
            }
        }
        $MaximumFollowRelLink = [int]::MaxValue
        switch ($MaxItems) {
            { $_ -le 0 } {
                $_AbortProcess = $true
                return
            }
            ([int]::MaxValue) {
                # do nothing
            }
            Default {
                # Currently, GitHub API per_page parameter is 100.
                # (call GET https://api.github.com/repos/PowerShell/PowerShell/releases?per_page=100)
                $MaximumFollowRelLink = [System.Math]::Ceiling($MaxItems / 100)
                Write-Verbose "Set -MaxItems = $MaxItems, -MaximumFollowRelLink = $MaximumFollowRelLink"
            }
        }
        
        
    }
    process {
        if ($_AbortProcess) {
            return
        }

        $ghReseponses = switch ($PSCmdlet.ParameterSetName) {
            'Latest' {
                $specifiedVersionTag = (Find-PowerShellBuildStatus -Release $Release).ReleaseTag
                Write-Verbose "current -Latest version tag is $($specifiedVersionTag)"
                GetGitHubResponseByTag -VersionTagName $specifiedVersionTag -Token $Token
            }
            'VersionTag' {
                GetGitHubResponseByTag -VersionTagName $VersionTag -Token $Token
            }
            'Version' {
                $specifiedVersionTag = GetTagNameFromVersion -Version $Version
                Write-Verbose "current -Version version tag is $($specifiedVersionTag)"
                GetGitHubResponseByTag -VersionTagName $specifiedVersionTag -Token $Token
            }
            Default {
                GetGitHubResponseByRange -FromVer $MinimumVersion -ToVer $MaximumVersion -Token $Token -MaximumFollowRelLink $MaximumFollowRelLink
            }
        }
        if (-not $ghReseponses) {
            Write-Warning $Messages.Find_PowerShellRelease_001
            return
        }

        # output object
        $streamedCount = 0
        $objectsForOutput = [System.Collections.ArrayList]::new()
        foreach ($r in $ghReseponses) {
            $obj = ConvertResponseItemToObject -ResponseItem $r -SpecifiedVersion $Version
            # excude pre release version by default
            if ($PSCmdlet.ParameterSetName -eq 'Default') {
                if (-not $IncludePreRelease -and $obj.PreRelease) {
                    Write-Verbose "-IncludePreRelease filter excludes version $($obj.Version)"
                    continue
                }
                # stream output (non sorted)
                if ($AsStream.IsPresent) {
                    if ($streamedCount -lt $MaxItems) {
                        Write-Output $obj
                    }
                    $streamedCount += 1
                    continue
                }
            }
            [void]$objectsForOutput.Add($obj)
        }
    }
    end {
        switch ($objectsForOutput.Count) {
            0 {
                # do nothing
            }
            1 {
                $objectsForOutput[0]
            }
            Default {
                $objectsForOutput | Sort-Object -Property Version -Descending | Select-Object -First $MaxItems
            }
        }
    }
}

function GetTagNameFromVersion ([semver]$Version) {
    return ('v{0}' -f $Version)
} 

function GetVersionFromTag ([string]$VersionTag) {
    try {
        if ($VersionTag -match "^v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)($|-(?<Label>.+$))") {
            return [SemVer]::new($Matches.Major, $Matches.Minor, $Matches.Patch, $Matches.Label)
        }
        return $null
    } catch {
        return $null
    }
}

function SetHttpHeaders ([string]$Token) {
    if ([string]::IsNullOrEmpty($Token)) {
        return @{Accept = 'application/vnd.github.v3+json'}
    }
    return @{Accept = 'application/vnd.github.v3+json'; Authorization = "token $Token"}
}

function GetGitHubResponseByTag ([string]$VersionTagName, [string]$Token) {
    $uri = if ($VersionTagName -eq 'latest') {
        # treat 'latest' as special
        'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    } else {
        ('https://api.github.com/repos/PowerShell/PowerShell/releases/tags/{0}' -f $VersionTagName)
    }
    try {
        return (Invoke-RestMethod -Uri $uri -Headers (SetHttpHeaders -Token $Token))
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        Write-Verbose ('GetGitHubResponseByTag request error : {0}' -f $_)
        return $null
    } catch {
        Write-Error $_
        return $null
    }
}

function GetGitHubResponseByRange ([semver]$FromVer, [semver]$ToVer, [string]$Token, [int]$MaximumFollowRelLink) {
    # per_page=100 is max value...
    $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases?per_page=100'
    $resPages = @()
    try {
        $resPages += (Invoke-RestMethod -Uri $uri -MaximumFollowRelLink $MaximumFollowRelLink -FollowRelLink -Headers (SetHttpHeaders -Token $Token))
    } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        Write-Verbose ('GetGitHubResponseByRange request error : {0}' -f $_)
        return $null
    } catch {
        Write-Error $_
        return $null
    }
    foreach ($page in $resPages) {
        foreach ($res in @($page)) {
            # filter verssion
            $currentVer = GetVersionFromTag -VersionTag ($res.tag_name)
            if (-not $currentVer) {
                continue
            }
            if ($FromVer -and ($currentVer -lt $FromVer)) {
                Write-Verbose "FromVer filter exculedes version $currentVer"
                continue          
            }
            if ($ToVer -and ($currentVer -gt $ToVer)) {
                Write-Verbose "ToVer filter exculedes version $currentVer"
                continue
            }
            Write-Output $res
        }
   }
}

function ConvertResponseItemToObject ([PSCustomObject]$ResponseItem, [semver]$SpecifiedVersion) {
    if (-not $ResponseItem) {
        return $null
    }
    # convert to class
    $obj = [PowerShellCoreRelease]::new()
    $obj.ReleaseId = $ResponseItem.Id
    $obj.Tag = $ResponseItem.tag_name
    $obj.Version = if ($specifiedVersion) {
        $specifiedVersion
    } else {
        # detect version from tag
        GetVersionFromTag -VersionTag ($ResponseItem.tag_name)
    }
    $obj.Name = $ResponseItem.name
    $obj.Url = $ResponseItem.url
    $obj.HtmlUrl = $ResponseItem.html_url
    $obj.PreRelease = $ResponseItem.prerelease
    # treat some special versions as pre-release (before GitHub pre-release management versions)
    switch ($obj.Version) {
        { $_ -in ('6.1.0-preview.1', '6.1.0-preview.2', '6.1.0-preview.3') } { 
            $obj.PreRelease = $true
        }
        { $_ -lt '6.0.0' } {
            $obj.PreRelease = $true
        }
        Default {
            # do nothing
        }
    }
    $obj.Published = $ResponseItem.published_at
    $obj.Description = $ResponseItem.body
    # set assets
    $obj.Assets = [System.Collections.Generic.List[PowerShellCoreAsset]]::new()
    foreach ($asset in $ResponseItem.assets) {
        $item = [PowerShellCoreAsset]::new()
        $item.Name = $asset.name
        $item.Url = $asset.url
        $item.Label = $asset.label
        $item.Created = $asset.created_at
        $item.Size = $asset.size
        $item.DownloadUrl = $asset.browser_download_url
        $obj.Assets.Add($item)
    }
    return $obj
}
