$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force
. (Join-Path $RootPath 'PowerShellCoreApiToken.ps1')

Describe "Set-PowerShellCoreApiToken, Get-PowerShellCoreApiToken, Remove-PowerShellCoreApiToken unit tests" {

    BeforeAll {
        $token = '1234567890'
        $maskedToken = '12345*****'

        if (Test-Path "~/.pscoreupdate") {
            Move-Item "~/.pscoreupdate" "~/.pscoreupdate.backup"
        }
    }

    AfterAll {
        if (Test-Path "~/.pscoreupdate") {
            Remove-Item "~/.pscoreupdate"
        }
        if (Test-Path "~/.pscoreupdate.backup") {
            Move-Item "~/.pscoreupdate.backup" "~/.pscoreupdate"
        }
    }

    It "Should create ~/.pscoreupdate configuration file" {
        Set-PowerShellCoreApiToken -Token $token
        Test-Path -Path "~/.pscoreupdate" | Should -BeTrue
        $json = Get-Content -Path "~/.pscoreupdate" -Raw | ConvertFrom-Json 
        $json.GitHubApiToken | Should -Not -BeNullOrEmpty
    }

    It "Should get proper token" {
        GetPowerShellCoreApiTokenImpl | Should -Be $token
    }

    It "Should display masked token" {
        Get-PowerShellCoreApiToken *>&1 | Should -Be ('Saved GitHub API token is : {0}' -f $maskedToken)
    }

    It "Should remove ~/.pscoreupdate configuration file" {
        Remove-PowerShellCoreApiToken
        Test-Path -Path "~/.pscoreupdate" | Should -BeFalse
    }
}