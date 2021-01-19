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
    # This function supports Windows, macOS only
    if (-not ($IsWindows -or $IsMacOS)) {
        Write-Warning $Messages.Update_PowerShellRelease_001
        return
    }

    # Find update version
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
        Write-Warning $Messages.Update_PowerShellRelease_002
        return
    }
    if ($psReleaseInfo.Version -lt $PSVersionTable.PSVersion -and (-not $Force)) {
        Write-Warning $Messages.Update_PowerShellRelease_003
        return
    }
    if ($psReleaseInfo.Version -eq $PSVersionTable.PSVersion -and (-not $Force)) {
        $releaseName = switch ($Release) {
            'Preview' { $Messages.Update_PowerShellRelease_012 }
            'LTS' { $Messages.Update_PowerShellRelease_013 }
            Default { $Messages.Update_PowerShellRelease_014 }
        }
        Write-Warning ($Messages.Update_PowerShellRelease_004 -f $releaseName)
        return
    }
    WriteInfo ($Messages.Update_PowerShellRelease_005 -f $psReleaseInfo.Version)

    # Download installer asset
    $installerAssetUrls = GetInstallerAssetUrls -Release $psReleaseInfo
    if (@($installerAssetUrls).Count -eq 0) {
        Write-Error $Messages.Update_PowerShellRelease_006
        return
    }
    if (@($installerAssetUrls).Count -gt 1) {
        Write-Warning $Messages.Update_PowerShellRelease_007
        return
    }
    $localInstallerPath = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath $installerAssetUrls.split("/")[-1]
    if ($PSCmdlet.ShouldProcess('Download PowerShell installer asset')) {
        DownloadFile -Uri $installerAssetUrls -OutFile $localInstallerPath -Token $Token
    } else {
        Write-Warning $Messages.Update_PowerShellRelease_008
        WriteInfo ("(Skip) Download {0}`r`n       To {1}..." -f $installerAssetUrls, $localInstallerPath)
    }

    # Do install
    $shouldInstall = $PSCmdlet.ShouldProcess('Install PowerShell')
    WriteInfo ($Messages.Update_PowerShellRelease_009 -f $psReleaseInfo.Version)
    $params = @{
        CustomParameters = @{
            Windows = @{
                NewVersion = $psReleaseInfo.Version
            }
        }
        CommonParameters = [InstallCommonParameters]@{
            InstallerPath  = $localInstallerPath
            InstallOptions = $InstallOptions
            Silent         = $Silent
            ShouldProcess  = $shouldInstall
        }
        
    }
    DoInstall @params

    # Exit PowerShel Console
    if ((-not $NotExitConsole) -or $Silent) {
        WriteInfo $Messages.Update_PowerShellRelease_011
        if ($shouldInstall) {
            Start-Sleep -Seconds 1
            exit 
        } else {
            WriteInfo '(skip) exit console.'
            return 
        }
    }
}

function GetInstallerAssetUrls ([PowerShellCoreRelease]$Release) {
    if ($IsWindows) {
        return GetMSIAssetUrls -Release $Release
    } 
    if ($IsMacOS) {
        return GetPKGAssetUrls -Release $Release
    }
    return
}

function GetMSIAssetUrls ([PowerShellCoreRelease]$Release) {
    if (IsCurrentProcess64bit) {
        return ($Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::MSI_WIN64 }).DownloadUrl.OriginalString
    }
    return ($Release.Assets | Where-Object { $_.Architecture -eq [AssetArchtectures]::MSI_WIN32 }).DownloadUrl.OriginalString
}

# this function is for unit tests mainly
function GetDarwinVersion () {
    return [System.Environment]::OSVersion.Version.Major
}

function GetPKGAssetUrls ([PowerShellCoreRelease]$Release) {
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
        { $_ -in (16, 17) } {
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

class InstallCommonParameters {

    [string]$InstallerPath

    [hashtable]$InstallOptions

    [bool]$Silent

    [bool]$ShouldProcess
}

function DoInstall ([hashtable]$CustomParameters, [InstallCommonParameters]$CommonParameters) {
    if ($IsWindows) {
        InstallMSI -NewVersion $CustomParameters["Windows"]["NewVersion"] -CommonParameters $CommonParameters
        return
    }
    if ($IsMacOS) {
        InstallPKG -CommonParameters $CommonParameters
        return
    }
    return
}

function InstallMSI ([SemVer]$NewVersion, [InstallCommonParameters]$CommonParameters) { 
    $msiArgs = @('/i', '"{0}"' -f $CommonParameters.InstallerPath)
    if ($CommonParameters.Silent) {
        $msiArgs += '/passive'
    }
    # Set the default install options if not specified.
    # Note : These options are valid only for silent installation.
    if ($null -eq $CommonParameters.InstallOptions) {
        if ($NewVersion -ge '6.1.0-preview.2') {
            $CommonParameters.InstallOptions = @{
                ADD_PATH          = 1;
                REGISTER_MANIFEST = 1;
            }
        }
    }
    if ($null -ne $CommonParameters.InstallOptions) {
        # Currently following parameters are allowed.
        #   INSTALLFOLDER = "C:\PowerShell\" : Install folder
        #   ADD_PATH = [0|1]          : Add PowerShell to Path Environment Variable
        #   REGISTER_MANIFEST = [0|1] : Register Windows Event Logging Manifest
        #   ENABLE_PSREMOTING = [0|1] : Enable PowerShell remoting
        #   ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL = [0|1] : Add 'Open here' context menus to Explorer
        foreach ($key in $CommonParameters.InstallOptions.Keys) {
            $msiArgs += ('{0}={1}' -f $key, $CommonParameters.InstallOptions[$key])
        }
    }
    if ($CommonParameters.ShouldProcess) {
        WriteInfo ('msiexec.exe {0}' -f ($msiArgs -join ' '))
        Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs
    } else {
        Write-Warning $Messages.Update_PowerShellRelease_010
        WriteInfo ('(skip) msiexec.exe {0}' -f ($msiArgs -join ' '))
    }
}

function InstallPKG ([InstallCommonParameters]$CommonParameters) { 
    # [string]$PkgFile, [bool]$Silent, [hashtable]$InstallOptions, [bool]$ShouldProcess) {
    $targetVolume = '/'
    if ($null -ne $CommonParameters.InstallOptions) {
        # Install volume
        if ($CommonParameters.InstallOptions.ContainsKey('target')) {
            $targetVolume = $CommonParameters.InstallOptions['target']
        }
    }
    if ($CommonParameters.Silent) {
        if ($CommonParameters.ShouldProcess) {
            WriteInfo "/usr/bin/sudo /usr/sbin/installer -pkg ""$($CommonParameters.InstallerPath)"" -target $targetVolume"
            /usr/bin/sudo /usr/sbin/installer -pkg "$($CommonParameters.InstallerPath)" -target $targetVolume
        } else {
            Write-Warning $Messages.Update_PowerShellRelease_010
            WriteInfo "(skip) /usr/bin/sudo /usr/sbin/installer -pkg ""$($CommonParameters.InstallerPath)"" -target $targetVolume"
        }
        return
    }
    if ($CommonParameters.ShouldProcess) {
        WriteInfo "Invoke-Item ""$($CommonParameters.InstallerPath)"""
        Invoke-Item "$($CommonParameters.InstallerPath)"
    } else {
        Write-Warning $Messages.Update_PowerShellRelease_010
        WriteInfo "(skip) Invoke-Item ""$($CommonParameters.InstallerPath)"""
    }
}