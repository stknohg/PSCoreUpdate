$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Test-LatestVersion unit tests" {

    BeforeAll {
        $Token = $env:GITHUB_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GITHUB_ACCESS_TOKEN is empty.'
        }
    }

    It "Test-LatestVersion exit normaly" {
        { Test-LatestVersion -Token $Token } | Should -Not -Throw
    }

    It "Test-LatestVersion -ExcludePreRelease exit normaly" {
        { Test-LatestVersion -ExcludePreRelease -Token $Token } | Should -Not -Throw
    }

    It "Test-LatestVersion -PassThru returns a result object" {
        $result = Test-LatestVersion -Token $Token -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Result | Should -BeOfType 'bool'
        $result.Release | Should -Not -BeNullOrEmpty
    }

    It "Test-LatestVersion -ExcludePreRelease -PassThru returns a result object" {
        $result = Test-LatestVersion -ExcludePreRelease -Token $Token -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Result | Should -BeOfType 'bool'
        $result.Release | Should -Not -BeNullOrEmpty
    }
}