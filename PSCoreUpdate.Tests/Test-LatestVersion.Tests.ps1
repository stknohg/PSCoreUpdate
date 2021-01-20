$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Test-LatestVersion unit tests" {

    BeforeAll {
        $Token = $env:GH_API_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GH_API_ACCESS_TOKEN is empty.'
        }
    }

    It "Test-LatestVersion returns normaly" {
        { Test-LatestVersion } | Should -Not -Throw
    }

    It "Test-LatestVersion -Release Preview exit normaly" {
        { Test-LatestVersion -Release Preview } | Should -Not -Throw
    }

    It "Test-LatestVersion -Release LTS exit normaly" {
        { Test-LatestVersion -Release LTS } | Should -Not -Throw
    }

    It "Test-LatestVersion -PassThru returns a result object" {
        $actual = Test-LatestVersion -PassThru
        $actual | Should -Not -BeNullOrEmpty
        $actual.Result | Should -Not -BeNullOrEmpty
        $actual.Result | Should -BeOfType 'bool'
        $actual.Release | Should -Be 'Stable'
        $actual.LatestVersion | Should -Not -BeNullOrEmpty
        $actual.LatestVersion | Should -BeOfType 'semver'
    }

    It "Test-LatestVersion -Release Preview -PassThru returns a result object" {
        $actual = Test-LatestVersion -Release Preview -PassThru
        $actual | Should -Not -BeNullOrEmpty
        $actual.Result | Should -Not -BeNullOrEmpty
        $actual.Result | Should -BeOfType 'bool'
        $actual.Release | Should -Be 'Preview'
        $actual.LatestVersion | Should -Not -BeNullOrEmpty
        $actual.LatestVersion | Should -BeOfType 'semver'
    }

    It "Test-LatestVersion -Release LTS -PassThru returns a result object" {
        $actual = Test-LatestVersion -Release LTS -PassThru
        $actual | Should -Not -BeNullOrEmpty
        $actual.Result | Should -Not -BeNullOrEmpty
        $actual.Result | Should -BeOfType 'bool'
        $actual.Release | Should -Be 'LTS'
        $actual.LatestVersion | Should -Not -BeNullOrEmpty
        $actual.LatestVersion | Should -BeOfType 'semver'
    }

}