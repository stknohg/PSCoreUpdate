<#
.SYNOPSIS
    Find PowerShell support status.
#>
function Find-PowerShellSupportStatus {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory = $false)]
        [SemVer]$Version,
        [Parameter(ParameterSetName = 'ExcludeEOS', Mandatory = $true)]
        [Switch]$ExcludeEOS
    )
    begin {
        # validate parameters
        $_AbortProcess = $false
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                if ( $Version -and ($Version.PreReleaseLabel -or $Version.BuildLabel)) {
                    Write-Error ($Messages.Find_PowerShellSupportStatus_001 -f $Version)
                    $_AbortProcess = $true
                    return
                }
            }
            
        }
    }
    process {
        if ($_AbortProcess) {
            $objectsForOutput = @()
            return
        }

        # Get PowerShell EOS information
        try {
            # Use endoflife.date raw data to get PowerShell EOS.
            Write-Verbose 'Request to https://raw.githubusercontent.com/endoflife-date/release-data/main/releases/powershell.json'
            $eols = Invoke-RestMethod -Uri https://raw.githubusercontent.com/endoflife-date/release-data/main/releases/powershell.json
        } catch {
            Write-Error 'Failed to get PowerShell EOS information.'
            return $null
        }

        # Create PowerShellEOS objects
        $objectsForOutput = [System.Collections.ArrayList]::new()
        foreach ($r in $eols.releases.PSObject.Properties.Name) {
            $obj = [PowerShellSupportStatus]::new()
            $obj.Version = [semver]$r
            $obj.EOSDate = [datetime]::Parse($eols.releases.$r.eol)
            # filter objcets
            if ($PSCmdlet.ParameterSetName -eq 'Default') {
                if ($Version -and 
                    -not ($Version.Major -eq $obj.Version.Major -and $Version.Minor -eq $obj.Version.Minor)) {
                    Write-Verbose "-Version filter excludes version $($obj.Version)"
                    continue
                }
            }
            if ($PSCmdlet.ParameterSetName -eq 'ExcludeEOS') {
                if ($obj.IsEOS() -eq $ExcludeEOS) {
                    Write-Verbose "-ExcludeEOS filter excludes version $($obj.Version)"
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
                $objectsForOutput | Sort-Object -Property Version -Descending
            }
        }
    }
}

