$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Save-PowerShellCore unit tests" {

    BeforeAll {
        $Token = $env:GH_API_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GH_API_ACCESS_TOKEN is empty.'
        }
    }

    It "Returns stable build status by default" {
        $expected = Invoke-RestMethod -Uri https://aka.ms/pwsh-buildinfo-stable
        $actual = Find-PowerShellBuildStatus
        $actual.Release | Should -Be 'Stable'
        $actual.ReleaseDate | Should -Be $expected.ReleaseDate
        $actual.ReleaseTag | Should -Be $expected.ReleaseTag
    }

    It "Get correct stable build status" {
        $expected = Invoke-RestMethod -Uri https://aka.ms/pwsh-buildinfo-stable
        $actual = Find-PowerShellBuildStatus -Release Stable
        $actual.Release | Should -Be 'Stable'
        $actual.ReleaseDate | Should -Be $expected.ReleaseDate
        $actual.ReleaseTag | Should -Be $expected.ReleaseTag
    }

    It "Get correct preview build status" {
        $expected = Invoke-RestMethod -Uri https://aka.ms/pwsh-buildinfo-preview
        $actual = Find-PowerShellBuildStatus -Release Preview
        $actual.Release | Should -Be 'Preview'
        $actual.ReleaseDate | Should -Be $expected.ReleaseDate
        $actual.ReleaseTag | Should -Be $expected.ReleaseTag
    }

    It "Get correct LTS build status" {
        $expected = Invoke-RestMethod -Uri https://aka.ms/pwsh-buildinfo-lts
        $actual = Find-PowerShellBuildStatus -Release LTS
        $actual.Release | Should -Be 'LTS'
        $actual.ReleaseDate | Should -Be $expected.ReleaseDate
        $actual.ReleaseTag | Should -Be $expected.ReleaseTag
    }
}