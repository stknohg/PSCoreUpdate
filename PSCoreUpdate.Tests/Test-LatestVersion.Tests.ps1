$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Test-LatestVersion unit tests" {

    BeforeAll {
        $Token = $env:GH_API_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GH_API_ACCESS_TOKEN is empty.'
        }
    }

    It "Test-LatestVersion exit normaly" {
        { Test-LatestVersion -Token $Token } | Should -Not -Throw
    }

    It "Test-LatestVersion -IncludePreRelease exit normaly" {
        { Test-LatestVersion -IncludePreRelease -Token $Token } | Should -Not -Throw
    }

    It "Test-LatestVersion -PassThru returns a result object" {
        $result = Test-LatestVersion -Token $Token -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Result | Should -BeOfType 'bool'
        $result.Release | Should -Not -BeNullOrEmpty
    }

    It "Test-LatestVersion -IncludePreRelease -PassThru returns a result object" {
        $result = Test-LatestVersion -IncludePreRelease -Token $Token -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Result | Should -BeOfType 'bool'
        $result.Release | Should -Not -BeNullOrEmpty
    }
}