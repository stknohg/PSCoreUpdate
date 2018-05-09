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
        [hashtable]$InstallOptions,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$NotExitConsole,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$ExcludePreRelease,
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
    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellCoreApiTokenImpl
    }
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $newVersion = Find-PowerShellCore -Version $Version -Token $specifiedToken -ExcludePreRelease:$ExcludePreRelease
        }
        Default {
            $newVersion = Find-PowerShellCore -Latest -Token $specifiedToken -ExcludePreRelease:$ExcludePreRelease
        }
    }
    if ($null -eq $newVersion) {
        Write-Warning 'No updates found.'
        return
    }
    if ($newVersion.Version -lt $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning ('No updates found.' -f $newVersion.Version)
        return
    }
    if ($newVersion.Version -eq $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning 'Current version is the latest.'
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
        DownloadFile -Uri $downloadURL -OutFile $fileName -Token $specifiedToken
    } else {
        Write-Warning 'Skip downloading asset file.'
    }

    # Install
    WriteInfo ('Start install PowerShell Core {0} .' -f $newVersion.Version)
    $shouldProcess = $PSCmdlet.ShouldProcess('Install PowerShell Core')
    if (-not $shouldProcess) {
        Write-Warning 'Skip installing PowerShell Core.'
    }
    if ($IsWindows) {
        InstallMSI -NewVersion $newVersion.Version -MsiFile $fileName -Silent $Silent -InstallOptions $InstallOptions -ShouldProcess $shouldProcess
    } elseif ($IsMacOS) {
        InstallPKG -PkgFile $fileName -Silent $Silent -InstallOptions $InstallOptions -ShouldProcess $shouldProcess
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
        return ($Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::MSI_WIN64 }).DownloadUrl.OriginalString
    }
    return ($Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::MSI_WIN32 }).DownloadUrl.OriginalString
}

function GetPKGDownloadUrl ([PowerShellCoreRelease]$Release) {
    $architecture = switch ([System.Environment]::OSVersion.Version.Major) {
        15 { [AssetArchtectures]::PKG_OSX1011 } # OSX El Capitan (10.11)
        16 { [AssetArchtectures]::PKG_OSX1012 } # macOS Sierra (10.12)
        17 { [AssetArchtectures]::PKG_OSX1012 } # macOS High Sierra (10.13)
        Default { [AssetArchtectures]::Unknown }
    }
    return ($Release.Assets | Where-Object { $_.Architecture -eq $architecture }).DownloadUrl.OriginalString
}

function InstallMSI ([SemVer]$NewVersion, [string]$MsiFile, [bool]$Silent, [hashtable]$InstallOptions, [bool]$ShouldProcess) {
    $args = @('/i', $MsiFile)
    if ($Silent) {
        $args += '/passive'
    }
    # Set the default install options if not specified.
    # Note : These options are valid only for silent installation.
    if ($null -eq $InstallOptions) {
        if ($NewVersion -ge '6.1.0-preview.2') {
            $InstallOptions = @{
                ADD_PATH          = 1;
                REGISTER_MANIFEST = 1;
            }
        }
    }
    if ($null -ne $InstallOptions) {
        # Currently following parameters are allowed.
        #   INSTALLFOLDER = "C:\PowerShell\" : Install folder
        #   ADD_PATH = [0|1]          : Add PowerShell to Path Environment Variable
        #   REGISTER_MANIFEST = [0|1] : Register Windows Event Logging Manifest
        #   ENABLE_PSREMOTING = [0|1] : Enable PowerShell remoting
        #   ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL = [0|1] : Add 'Open here' context menus to Explorer
        foreach ($key in $InstallOptions.Keys) {
            $args += ('{0}={1}' -f $key, $InstallOptions[$key])
        }
    }
    WriteInfo ('msiexec.exe {0}' -f ($args -join ' '))
    if ($ShouldProcess) {
        Start-Process -FilePath 'msiexec.exe' -ArgumentList $args
    }
}

function InstallPKG ([string]$PkgFile, [bool]$Silent, [hashtable]$InstallOptions, [bool]$ShouldProcess) {
    $targetVolume = '/'
    if ($null -ne $InstallOptions) {
        # Install volume
        if ($InstallOptions.ContainsKey('target')) {
            $targetVolume = $InstallOptions['target']
        }
    }
    if ($Silent) {
        WriteInfo "/usr/bin/sudo /usr/sbin/installer -pkg ""$PkgFile"" -target $targetVolume"
        if ($ShouldProcess) {
            /usr/bin/sudo /usr/sbin/installer -pkg "$PkgFile" -target $targetVolume
        }
        return
    }
    WriteInfo "Invoke-Item $PkgFile"
    if ($ShouldProcess) {
        Invoke-Item $PkgFile
    }
}