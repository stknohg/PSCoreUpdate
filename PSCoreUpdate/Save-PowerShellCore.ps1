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
        [AssetArchtectures]$AssetType,
        [Parameter(ParameterSetName = 'Default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [string]$OutDirectory
    )
    if ($AssetType -eq [AssetArchtectures]::Unknown) {
        Write-Error 'Invalid AssetType.'
        return
    }

    # find release
    $release = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $release = Find-PowerShellCore -MinimamVersion $Version | Where-Object { $_.Version -eq $Version }
        }
        Default {
            $release = Find-PowerShellCore -Latest
        }
    }
    if ($null -eq $release) {
        Write-Warning 'No release found.'
        return
    }
    WriteInfo ('Start download PowerShell Core {0} ...' -f $release.Version)

    # download
    $downloadUrl = ($release.Assets | Where-Object { $_.Architecture() -eq $AssetType }).DownloadUrl.OriginalString
    if ($downloadUrl -eq '') {
        Write-Error 'asset not found.'
        return
    }
    $outFile = Join-Path $OutDirectory $downloadURL.split("/")[-1]
    WriteInfo ('Download {0}' -f $downloadURL)
    WriteInfo ('  To {0} ...' -f $outFile)
    if ($PSCmdlet.ShouldProcess('Download file')) {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outFile
    } else {
        Write-Warning 'Skip downloaging the file.'
    }
}
