<#
.SYNOPSIS
    Find PowerShell releases.
#>
function Find-PowerShellRelease {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'Default')]
        [string]$VersionRange,
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
        [Switch]$NoCache,
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
            'Default' {
                # validate max items
                switch ($MaxItems) {
                    { $_ -le 0 } {
                        $_AbortProcess = $true
                        return
                    }
                    Default {
                        # do nothing
                        Write-Verbose "Set -MaxItems = $MaxItems"
                    }
                }
                # validate version range
                $parseResult = ParseVersionQuery -Query $VersionRange
                if (-not $parseResult.Result) {
                    Write-Error ($Messages.Find_PowerShellRelease_003 -f $VersionRange)
                    $_AbortProcess = $true
                    return
                }
                $MinVersion = $parseResult.MinVersion
                $IsMinInclusive = $parseResult.IsMinInclusive
                $MaxVersion = $parseResult.MaxVersion
                $IsMaxInclusive = $parseResult.IsMaxInclusive
                Write-Verbose "Set FromVersion $(if($IsMinInclusive){'=>'}else{('>')}) $MinVersion, ToVersion $(if($IsMaxInclusive){'=<'}else{('<')}) $MaxVersion"
                # validate NoCache
                if ($NoCache.IsPresent) {
                    Write-Verbose "Set cache is expired."
                    $global:g_GitHubReleaseCache.ExpireAt = [datetime]::MinValue
                    $global:g_GitHubReleaseCache.Pages = $null
                }
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
                GetGitHubResponseByRange -FromVer $MinVersion -IsFromInclusive $IsMinInclusive `
                                         -ToVer $MaxVersion -IsToInclusive $IsMaxInclusive -Token $Token
            }
        }
        if (-not $ghReseponses) {
            Write-Warning $Messages.Find_PowerShellRelease_001
            return
        }

        # output object
        $objectsForOutput = [System.Collections.ArrayList]::new()
        foreach ($r in $ghReseponses) {
            $obj = ConvertResponseItemToObject -ResponseItem $r -SpecifiedVersion $Version
            # excude pre release version by default
            if ($PSCmdlet.ParameterSetName -eq 'Default') {
                if (-not $IncludePreRelease -and $obj.PreRelease) {
                    Write-Verbose "-IncludePreRelease filter excludes version $($obj.Version)"
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

function ParseVersionQuery ([string]$Query) {
    # To avoid Nuget.Versioning.dll assembly load conflict, we call test script as a job (as a external process).
    # Note : Don't use ThreadJob.
    try {
        $job = Start-Job (Join-Path $PSScriptRoot 'Test-NugetVersionRange.ps1') -ArgumentList ($Query) -WorkingDirectory $PSScriptRoot
        $result = $job | Receive-Job -Wait
    } finally {
        if ($job) {
            $job | Remove-Job
        }
    }
    foreach ($log in $result.VerboseLogs) {
        Write-Verbose $log
    }
    return [PSCustomObject]@{
        Result = $result.Result
        MinVersion = [semver]$result.MinVersionString
        IsMinInclusive = $result.IsMinInclusive
        MaxVersion = [semver]$result.MaxVersionString
        IsMaxInclusive = $result.IsMaxInclusive
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


# very simple cache
$global:g_GH_CACHE_MINUTES = 10
$global:g_GitHubReleaseCache = [PSCustomObject]@{
    ExpireAt = [datetime]::MinValue;
    Pages = $null;
}

function GetGitHubResponseByRange ([semver]$FromVer, [bool]$IsFromInclusive,
                                   [semver]$ToVer, [bool]$IsToInclusive, [string]$Token) {

    if ([datetime]::Now -ge $global:g_GitHubReleaseCache.ExpireAt) {
        # per_page=100 is max value...
        $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases?per_page=100'
        $resPages = @()
        try {
            $resPages += (Invoke-RestMethod -Uri $uri -FollowRelLink -Headers (SetHttpHeaders -Token $Token))
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            Write-Verbose ('GetGitHubResponseByRange request error : {0}' -f $_)
            return $null
        } catch {
            Write-Error $_
            return $null
        }
        # set cache
        $global:g_GitHubReleaseCache.ExpireAt = [datetime]::Now.AddMinutes($global:g_GH_CACHE_MINUTES)
        $global:g_GitHubReleaseCache.Pages = $resPages
        Write-Verbose "Set cache response : ExpireAt = $($global:g_GitHubReleaseCache.ExpireAt), Pages = $($global:g_GitHubReleaseCache.Pages.Count)"
    } else {
        Write-Verbose "Use cache response : ExpireAt = $($global:g_GitHubReleaseCache.ExpireAt), Pages = $($global:g_GitHubReleaseCache.Pages.Count)"
        $resPages = $global:g_GitHubReleaseCache.Pages
    }
    foreach ($page in $resPages) {
        foreach ($res in @($page)) {
            # filter version
            $currentVer = GetVersionFromTag -VersionTag ($res.tag_name)
            if (-not $currentVer) {
                Write-Verbose "Failed to get version from $($res.tag_name)"
                continue
            }
            if ($FromVer -and ($currentVer -lt $FromVer)) {
                Write-Verbose "FromVer filter exculedes version $currentVer"
                continue          
            }
            if ($FromVer -and ($currentVer -eq $FromVer) -and (-not $IsFromInclusive)) {
                Write-Verbose "FromVer filter exculedes version $currentVer"
                continue          
            }
            if ($ToVer -and ($currentVer -gt $ToVer)) {
                Write-Verbose "ToVer filter exculedes version $currentVer"
                continue
            }
            if ($ToVer -and ($currentVer -eq $ToVer) -and (-not $IsToInclusive)) {
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
