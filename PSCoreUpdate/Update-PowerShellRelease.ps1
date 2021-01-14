<#
.SYNOPSIS
    Update PowerShell to the specified version.
#>
function Update-PowerShellRelease {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default')]
        [Switch]$Latest,
        [Parameter(ParameterSetName = 'Default')]
        [ReleaseTypes]$Release = [ReleaseTypes]::Stable,
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
        [string]$Token,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Version')]
        [Switch]$Force
    )
    # currently, supports windows only
    if (-not ($IsWindows -or $IsMacOS)) {
        Write-Warning $Messages.Update_PowerShellRelease_001
        return
    }

    # find update version
    $newVersion = $null
    $specifiedToken = $Token
    if ([string]::IsNullOrEmpty($specifiedToken)) {
        $specifiedToken = GetPowerShellGitHubApiTokenImpl
    }
    switch ($PSCmdlet.ParameterSetName) {
        'Version' {  
            $newVersion = Find-PowerShellRelease -Version $Version -Token $specifiedToken -IncludePreRelease
        }
        Default {
            switch ($Release) {
                'Preview' {
                    $newVersion = Find-PowerShellRelease -Token $specifiedToken `
                                    -Version ((Find-PowerShellBuildStatus -Release Preview).Version) `
                                    -IncludePreRelease
                }
                'LTS' {
                    $newVersion = Find-PowerShellRelease -Token $specifiedToken `
                                    -Version ((Find-PowerShellBuildStatus -Release LTS).Version)
                }
                Default {
                    $newVersion = Find-PowerShellRelease -Token $specifiedToken `
                                    -Latest 
                }
            }
        }
    }
    if ($null -eq $newVersion) {
        Write-Warning $Messages.Update_PowerShellRelease_002
        return
    }
    if ($newVersion.Version -lt $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning $Messages.Update_PowerShellRelease_003
        return
    }
    if ($newVersion.Version -eq $PSVersionTable.PSVersion -and (-not $Force)) {
        switch ($Release) {
            'Preview' {
                Write-Warning ($Messages.Update_PowerShellRelease_004 -f $Messages.Update_PowerShellRelease_012)
            }
            'LTS' {
                Write-Warning ($Messages.Update_PowerShellRelease_004 -f $Messages.Update_PowerShellRelease_013)
            }
            Default {
                Write-Warning ($Messages.Update_PowerShellRelease_004 -f $Messages.Update_PowerShellRelease_014)
            }
        }
        return
    }
    WriteInfo ($Messages.Update_PowerShellRelease_005 -f $newVersion.Version)

    # Download asset
    $downloadURL = @()
    if ($IsWindows) {
        $downloadURL = GetMSIDownloadUrl -Release $newVersion
    } elseif ($IsMacOS) {
        $downloadURL = GetPKGDownloadUrl -Release $newVersion
    } else {
        # TODO : update
        Write-Warning $Messages.Update_PowerShellRelease_001
        return
    }
    if (@($downloadURL).Length -eq 0) {
        Write-Error $Messages.Update_PowerShellRelease_006
        return
    }
    if (@($downloadURL).Length -gt 1) {
        Write-Warning $Messages.Update_PowerShellRelease_007
        return
    }
    $fileName = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath $downloadURL.split("/")[-1]
    if ($PSCmdlet.ShouldProcess('Download asset')) {
        DownloadFile -Uri $downloadURL -OutFile $fileName -Token $specifiedToken
    } else {
        Write-Warning $Messages.Update_PowerShellRelease_008
    }

    # Install
    WriteInfo ($Messages.Update_PowerShellRelease_009 -f $newVersion.Version)
    $shouldProcess = $PSCmdlet.ShouldProcess('Install PowerShell')
    if (-not $shouldProcess) {
        Write-Warning $Messages.Update_PowerShellRelease_010
    }
    if ($IsWindows) {
        InstallMSI -NewVersion $newVersion.Version -MsiFile $fileName -Silent $Silent -InstallOptions $InstallOptions -ShouldProcess $shouldProcess
    } elseif ($IsMacOS) {
        InstallPKG -PkgFile $fileName -Silent $Silent -InstallOptions $InstallOptions -ShouldProcess $shouldProcess
    } else {
        # TODO : implement
        Write-Warning $Messages.Update_PowerShellRelease_001
        return
    }

    # Exit PowerShel Console
    if ((-not $NotExitConsole) -or $Silent) {
        WriteInfo $Messages.Update_PowerShellRelease_011
        Start-Sleep -Seconds 1
        if (-not $shouldProcess) {
            return 
        }
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
    switch (GetDarwinVersion) {
        15 {
            # PKG_OSX1011
            # * OSX El Capitan (10.11)
            $asset = $Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::PKG_OSX1011 }
            if ($null -ne $asset) {
                return $asset.DownloadUrl.OriginalString
            }
            return
        } 
        {$_ -in (16, 17)} {
            # PKG_OSX1012 or PKG_OSX
            # macOS Sierra (10.12)
            # macOS High Sierra (10.13)
            $asset = $Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::PKG_OSX }
            if ($null -ne $asset) {
                return $asset.DownloadUrl.OriginalString
            }
            $asset = $Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::PKG_OSX1012 }
            if ($null -ne $asset) {
                return $asset.DownloadUrl.OriginalString
            }
            return
        }
        Default {
            # PKG_OSX
            $asset = $Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::PKG_OSX }
            if ($null -ne $asset) {
                return $asset.DownloadUrl.OriginalString
            }
            return
        }
    }
}

function GetDarwinVersion () {
    return [System.Environment]::OSVersion.Version.Major
}

function InstallMSI ([SemVer]$NewVersion, [string]$MsiFile, [bool]$Silent, [hashtable]$InstallOptions, [bool]$ShouldProcess) {
    $msiArgs = @('/i', $MsiFile)
    if ($Silent) {
        $msiArgs += '/passive'
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
            $msiArgs += ('{0}={1}' -f $key, $InstallOptions[$key])
        }
    }
    WriteInfo ('msiexec.exe {0}' -f ($msiArgs -join ' '))
    if ($ShouldProcess) {
        Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs
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