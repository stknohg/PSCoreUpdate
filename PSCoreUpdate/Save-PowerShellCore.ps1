<#
.SYNOPSIS
    Download PowerShell Core Asset
#>
function Save-PowerShellCore {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$Latest,
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
            Write-Error $Messages.Save_PowerShellCore_001
            return
        }
    } else {
        if ($AssetType -contains [AssetArchtectures]::Unknown) {
            Write-Error $Messages.Save_PowerShellCore_002
            return
        }
    }

    # find release
    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellCoreApiTokenImpl
    }
    $release = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $release = Find-PowerShellCore -Version $Version -IncludePreRelease -Token $specifiedToken
        }
        Default {
            $release = Find-PowerShellCore -Latest -Token $specifiedToken
        }
    }
    if ($null -eq $release) {
        Write-Warning $Messages.Save_PowerShellCore_003
        return
    }
    WriteInfo ($Messages.Save_PowerShellCore_004 -f $release.Version)

    # download
    foreach ($at in $AssetType) {
        $downloadUrls = ($release.Assets | Where-Object { $_.Architecture -eq $at }).DownloadUrl.OriginalString
        if (@($downloadUrls).Length -eq 0) {
            Write-Error $Messages.Save_PowerShellCore_005
            return
        }
        foreach ($url in $downloadUrls) {
            $outFile = Join-Path $OutDirectory $url.split("/")[-1]
            if ($PSCmdlet.ShouldProcess('Download file')) {
                DownloadFile -Uri $url -OutFile $outFile -Token $specifiedToken
            } else {
                Write-Warning $Messages.Save_PowerShellCore_006
            }
        }
    }
}
