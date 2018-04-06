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
            Write-Error 'Invalid AssetType.'
            return
        }
    } else {
        if ($AssetType -contains [AssetArchtectures]::Unknown) {
            Write-Error 'Invalid AssetType included.'
            return
        }
    }
    

    # find release
    $release = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $release = Find-PowerShellCore -MinimamVersion $Version -Token $Token | Where-Object { $_.Version -eq $Version }
        }
        Default {
            $release = Find-PowerShellCore -Latest -Token $Token
        }
    }
    if ($null -eq $release) {
        Write-Warning 'No release found.'
        return
    }
    WriteInfo ('Start download PowerShell Core {0} ...' -f $release.Version)

    # download
    foreach ($at in $AssetType) {
        $downloadUrls = ($release.Assets | Where-Object { $_.Architecture() -eq $at }).DownloadUrl.OriginalString
        if (@($downloadUrls).Length -eq 0) {
            Write-Error 'asset not found.'
            return
        }
        foreach ($url in $downloadUrls) {
            $outFile = Join-Path $OutDirectory $url.split("/")[-1]
            WriteInfo ('Download {0}' -f $url)
            WriteInfo ('  To {0} ...' -f $outFile)
            if ($PSCmdlet.ShouldProcess('Download file')) {
                if ([string]::IsNullOrEmpty($Token)) {
                    Invoke-WebRequest -Uri $url -OutFile $outFile
                } else {
                    Invoke-WebRequest -Uri $url -OutFile $outFile -Headers @{Authorization = "token $Token"}
                }
            } else {
                Write-Warning 'Skip downloaging the file.'
            }
        }
    }
}
