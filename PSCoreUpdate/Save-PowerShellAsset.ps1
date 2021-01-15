<#
.SYNOPSIS
    Download PowerShell Asset
#>
function Save-PowerShellAsset {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Default')]
        [ReleaseTypes]$Release = [ReleaseTypes]::Stable,
        [Parameter(ParameterSetName = 'Version')]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'Default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [AssetArchtectures[]]$AssetType,
        [Parameter(ParameterSetName = 'Default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [string]$OutDirectory,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [string]$Token
    )
    if (@($AssetType).Length -eq 1) {
        if ($AssetType[0] -eq [AssetArchtectures]::Unknown) {
            Write-Error $Messages.Save_PowerShellAsset_001
            return
        }
    } else {
        if ($AssetType -contains [AssetArchtectures]::Unknown) {
            Write-Error $Messages.Save_PowerShellAsset_002
            return
        }
    }

    # find PowerShell release
    $psReleaseInfo = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $psReleaseInfo = Find-PowerShellRelease -Version $Version -Token $Token
        }
        Default {
            $psReleaseInfo = Find-PowerShellRelease -Latest -Release $Release -Token $Token
        }
    }
    if (-not $psReleaseInfo) {
        Write-Warning $Messages.Save_PowerShellAsset_003
        return
    }
    WriteInfo ($Messages.Save_PowerShellAsset_004 -f $psReleaseInfo.Version)

    # download
    foreach ($at in $AssetType) {
        $downloadUrls = ($psReleaseInfo.Assets | Where-Object { $_.Architecture -eq $at }).DownloadUrl.OriginalString
        if (@($downloadUrls).Length -eq 0) {
            Write-Error $Messages.Save_PowerShellAsset_005
            return
        }
        foreach ($url in $downloadUrls) {
            $outFile = Join-Path $OutDirectory $url.split("/")[-1]
            if ($PSCmdlet.ShouldProcess('Download file')) {
                DownloadFile -Uri $url -OutFile $outFile -Token $specifiedToken
            } else {
                Write-Warning $Messages.Save_PowerShellAsset_006
            }
        }
    }
}
