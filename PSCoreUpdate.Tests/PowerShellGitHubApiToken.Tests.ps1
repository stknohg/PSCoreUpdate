$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

InModuleScope 'PSCoreUpdate' {
    Describe "Set-PowerShellGitHubApiToken, Get-PowerShellGitHubApiToken, Remove-PowerShellGitHubApiToken unit tests" {

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
            Set-PowerShellGitHubApiToken -Token $token
            Test-Path -Path "~/.pscoreupdate" | Should -BeTrue
            $json = Get-Content -Path "~/.pscoreupdate" -Raw | ConvertFrom-Json 
            $json.GitHubApiToken | Should -Not -BeNullOrEmpty
        }
    
        It "Should get proper token" {
            GetPowerShellGitHubApiTokenImpl | Should -Be $token
        }
    
        It "Should display masked token" {
            $info = Get-PowerShellGitHubApiToken *>&1
            $info.MessageData.Message.Contains($maskedToken) | Should -BeTrue
        }
    
        It "Should remove ~/.pscoreupdate configuration file" {
            Remove-PowerShellGitHubApiToken
            Test-Path -Path "~/.pscoreupdate" | Should -BeFalse
        }
    }
}