$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Find-PowerShellSupportStatus unit tests" {
    BeforeAll {
        # Get endoflife.date rawdata
        $EOSRawData = Invoke-RestMethod -Uri https://raw.githubusercontent.com/endoflife-date/release-data/main/releases/powershell.json
    }

    It "Returns proper data count" {
        $actual = Find-PowerShellSupportStatus
        $actual.Count | Should -Be @($EOSRawData.releases.PSObject.Properties).Length
    }

    It "Returns proper EOS date"  {
        $actual = Find-PowerShellSupportStatus
        $actual.Where({ $_.Version -eq '6.0' }).EOSDate | Should -Be ([datetime]::new(2019, 2, 13))
        $actual.Where({ $_.Version -eq '6.1' }).EOSDate | Should -Be ([datetime]::new(2019, 9, 28))
        $actual.Where({ $_.Version -eq '6.2' }).EOSDate | Should -Be ([datetime]::new(2020, 9, 4))
        $actual.Where({ $_.Version -eq '7.0' }).EOSDate | Should -Be ([datetime]::new(2022, 12, 3))
        $actual.Where({ $_.Version -eq '7.1' }).EOSDate | Should -Be ([datetime]::new(2022, 5, 8))
        $actual.Where({ $_.Version -eq '7.2' }).EOSDate | Should -Be ([datetime]::new(2024, 11, 8))
        $actual.Where({ $_.Version -eq '7.3' }).EOSDate | Should -Be ([datetime]::new(2024, 05, 08))
        $actual.Where({ $_.Version -eq '7.4' }).EOSDate | Should -Be ([datetime]::new(2026, 11, 10))
    }

    $testCases = @(
        @{Pattern = 'PowerShell 6.0'; PSVersion = '6.0'; EOSDate = [datetime]::new(2019, 2, 13) },
        @{Pattern = 'PowerShell 7.0'; PSVersion = '7.0'; EOSDate = [datetime]::new(2022, 12, 3) },
        @{Pattern = 'PowerShell 7.4'; PSVersion = '7.4'; EOSDate = [datetime]::new(2026, 11, 10) }
    )
    It "Returns specific version EOS date  (<Pattern>)" -TestCases $testCases {
        $actual = Find-PowerShellSupportStatus -Version $PSVersion
        # Check count
        $actual.Count | Should -Be 1
        # Check EOS date
        $actual.EOSDate | Should -Be $EOSDate
    }

    It "Raise error when specified preview version" {
        { Find-PowerShellSupportStatus -Version 7.5.0-preview.3 -ErrorAction Stop } | Should -Throw    
    }
}