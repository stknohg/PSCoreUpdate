<#
.SYNOPSIS
    Update PowerShell Core to the specified version.
#>
function Update-PowerShellCore {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Version')]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$Silent,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$NotExitConsole,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [string]$Token,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$Force
    )
    # currently, supports windows only
    if (-not ($IsWindows -or $IsMacOS)) {
        Write-Warning 'This cmdlet supports Windows/macOS Only.'
        return
    }

    # find update version
    $newVersion = $null
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $newVersion = Find-PowerShellCore -Version $Version -Token $Token
        }
        Default {
            $newVersion = Find-PowerShellCore -Latest -Token $Token
        }
    }
    if ($null -eq $newVersion) {
        Write-Warning 'No updates found.'
        return
    }
    if ($newVersion.Version -eq $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning 'No updates found.'
        return
    }
    if ($newVersion.Version -lt $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning ('PowerShell Core {0} is not newer version.' -f $newVersion.Version)
        return
    }
    WriteInfo ('Find new version PowerShell Core {0} ...' -f $newVersion.Version)

    # Download asset
    $downloadURL = @()
    if ($IsWindows) {
        $downloadURL = GetMSIDownloadUrl -Release $newVersion
    } elseif ($IsMacOS) {
        $downloadURL = GetPKGDownloadUrl -Release $newVersion
    } else {
        # TODO : update
        Write-Warning 'This cmdlet supports Windows/macOS Only.'
        return
    }
    if (@($downloadURL).Length -eq 0) {
        Write-Error 'Failed to get asset url.'
        return
    }
    if (@($downloadURL).Length -gt 1) {
        Write-Warning 'Multiple assets were found. This case is not supported currently.'
        return
    }
    $fileName = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath $downloadURL.split("/")[-1]
    if ($PSCmdlet.ShouldProcess('Download asset')) {
        DownloadFile -Uri $downloadURL -OutFile $fileName -Token $Token
    } else {
        Write-Warning 'Skip downloading asset file.'
    }

    # Install
    WriteInfo ('Start install PowerShell Core {0} .' -f $newVersion.Version)
    if (-not $PSCmdlet.ShouldProcess('Install PowerShell Core')) {
        Write-Warning 'Skip installing PowerShell Core.'
        return
    }
    if ($IsWindows) {
        InstallMSI -MsiFile $fileName -Silent $Silent
    } elseif ($IsMacOS) {
        InstallPKG -PkgFile $fileName -Silent $Silent
    } else {
        # TODO : implement
        Write-Warning 'This cmdlet supports Windows/macOS Only.'
        return
    }

    # Exit PowerShel Console
    if ((-not $NotExitConsole) -or $Silent) {
        WriteInfo 'Exit current PowerShell Console...'
        Start-Sleep -Seconds 1
        exit 
    }
}

function GetMSIDownloadUrl ([PowerShellCoreRelease]$Release) {
    if (IsCurrentProcess64bit) {
        return ($Release.Assets | Where-Object { $_.Architecture() -eq [AssetArchtectures]::MSI_WIN64 }).DownloadUrl.OriginalString
    } else {
        return ($Release.Assets | Where-Object { $_.Architecture() -eq [AssetArchtectures]::MSI_WIN32 }).DownloadUrl.OriginalString
    }
}

function GetPKGDownloadUrl ([PowerShellCoreRelease]$Release) {
    $prodcutVersion = ''
    try {
        $prodcutVersion = '{0}.{1}' -f (sw_vers -productVersion).split('.')
    }
    catch {
        # do nothing 
    }
    $architecture = switch ($prodcutVersion) {
        '10.11' { [AssetArchtectures]::PKG_OSX1011 }
        '10.12' { [AssetArchtectures]::PKG_OSX1012 }
        '10.13' { [AssetArchtectures]::PKG_OSX1012 }
        Default { [AssetArchtectures]::Unknown }
    }
    return ($Release.Assets | Where-Object { $_.Architecture() -eq $architecture }).DownloadUrl.OriginalString
}

function InstallMSI ([string]$MsiFile, [bool]$Silent) {
    $args = @()
    $args += '/i'
    $args += $MsiFile
    if ($Silent) {
        $args += '/passive'
    }
    Start-Process -FilePath 'msiexec.exe' -ArgumentList $args
}

function InstallPKG ([string]$PkgFile, [bool]$Silent) {
    if ($Silent) {
        /usr/bin/sudo /usr/sbin/installer -pkg "$PkgFile" -target /
    } else {
        Invoke-Item $PkgFile
    }
}