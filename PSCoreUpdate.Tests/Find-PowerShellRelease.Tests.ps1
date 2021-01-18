$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Find-PowerShellRelease unit tests" {

    BeforeAll {
        $Token = $env:GH_API_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GH_API_ACCESS_TOKEN is empty.'
        }
    }

    It "Returns nothing when specified invalid version" {
        Find-PowerShellRelease -Version 999.0.0 -Token $Token | Should -BeNullOrEmpty
        Find-PowerShellRelease -Version 0.0.1 -Token $Token | Should -BeNullOrEmpty
    }

    It "Should get stable version specified -Version parameter" {
        $actual = Find-PowerShellRelease -Version 7.0.0 -Token $Token
        $actual.Count | Should -Be 1
        $actual.Version | Should -Be '7.0.0'
    }

    It "Should get prerelease version specified -Version parameter" {
        $actual = Find-PowerShellRelease -Version 7.1.0-preview.1 -Token $Token
        $actual.Count | Should -Be 1
        $actual.Version | Should -Be '7.1.0-preview.1'
    }

    It "Should get the latest stable release information" {
        $target = Find-PowerShellRelease -Latest -Token $Token
        $expected = Find-PowerShellBuildStatus -Release Stable 
        $target.Version | Should -Be $expected.Version
        #
        $target = Find-PowerShellRelease -Latest -Release Stable -Token $Token
        $expected = Find-PowerShellBuildStatus -Release Stable 
        $target.Version | Should -Be $expected.Version
    }

    It "Should get the latest preview release information" {
        $target = Find-PowerShellRelease -Latest -Release Preview -Token $Token
        $expected = Find-PowerShellBuildStatus -Release Preview 
        $target.Version | Should -Be $expected.Version
    }

    It "Should get the latest LTS release information" {
        $target = Find-PowerShellRelease -Latest -Release LTS -Token $Token
        $expected = Find-PowerShellBuildStatus -Release LTS 
        $target.Version | Should -Be $expected.Version
    }

    It "Should get the range releases information(specify single version = set incusive minimum)" {
        $release = Find-PowerShellRelease -VersionRange '7.0.0' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Be '7.0.0'
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '7.0.0' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Be '7.0.0'
    }

    It "Should get the range releases information(specify mimimun version only - 1)" {
        $release = Find-PowerShellRelease -VersionRange '[7.0.0,]' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Be '7.0.0'
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '[7.0.0,]' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Be '7.0.0'
    }

    It "Should get the range releases information(specify mimimun version only - 2)" {
        $release = Find-PowerShellRelease -VersionRange '(7.0.0,]' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Not -Be '7.0.0'
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '(7.0.0,]' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release[-1].Version | Should -Not -Be '7.0.0'
    }

    It "Should get the range releases information(specify maximum verson only - 1)" {
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '[,6.0.0]' -Token $Token
        $release.Count | Should -Be 30
        $release = Find-PowerShellRelease -VersionRange '[,6.0.0]' -Token $Token
        $release.Count | Should -Be 1
    }

    It "Should get the range releases information(specify maximum verson only - 2)" {
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '[,6.0.0)' -Token $Token
        $release.Count | Should -Be 29
        $release = Find-PowerShellRelease -VersionRange '[,6.0.0)' -Token $Token
        $release.Count | Should -Be 0
    }


    It "Should treat the special versions as Preview" {
        # 6.1 preview 1 - 3
        $release = Find-PowerShellRelease -Version '6.1.0-preview.3' -Token $Token
        $release.PreRelease | Should -BeTrue
        $release = Find-PowerShellRelease -Version '6.1.0-preview.2' -Token $Token
        $release.PreRelease | Should -BeTrue
        $release = Find-PowerShellRelease -Version '6.1.0-preview.1' -Token $Token
        $release.PreRelease | Should -BeTrue
        # before 6.0
        $release = Find-PowerShellRelease -Version '6.0.0-rc.2' -Token $Token
        $release.PreRelease | Should -BeTrue
    }

    It "Should get the range releases information(specify MinimumVersion, MaximumVersion)" {
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '[6.0.0,6.1.0]' -Token $Token
        $release.Count | Should -Be 12
        $release = Find-PowerShellRelease -VersionRange '[6.0.0,6.1.0]' -Token $Token
        $release.Count | Should -Be 7
    }

    It "Should be result values sorted by default" {
        $release = Find-PowerShellRelease -IncludePreRelease -VersionRange '[6.1.0,6.2.0]' -Token $Token
        $release.Count | Should -BeGreaterThan 5
        $release[0].Version | Should -Be '6.2.0'
        $release[1].Version | Should -Be '6.2.0-rc.1'
        $release[2].Version | Should -Be '6.2.0-preview.4'
        $release[3].Version | Should -Be '6.2.0-preview.3'
        $release[4].Version | Should -Be '6.2.0-preview.2'
    }

    It "Should -MaxItems Parameter returns correct results" {
        $release = Find-PowerShellRelease -VersionRange '[6.1.0,6.2.0]' -MaxItems 0 -Token $Token
        $release.Count | Should -Be 0
        $release = Find-PowerShellRelease -VersionRange '[6.1.0,6.2.0]' -MaxItems 1 -Token $Token
        $release.Count | Should -Be 1
        $release = Find-PowerShellRelease -VersionRange '[6.1.0,6.2.0]' -MaxItems 5 -Token $Token
        $release.Count | Should -Be 5
    }

    It "Should get proper properties" {
        $release = Find-PowerShellRelease -Version 6.0.0 -Token $Token
        $release.Count | Should -Be 1
        # base properies
        $release.ReleaseId | Should -Be 9184057
        $release.Tag | Should -Be 'v6.0.0'
        $release.Name | Should -Be 'v6.0.0 release of PowerShell Core'
        $release.Url | Should -Be 'https://api.github.com/repos/PowerShell/PowerShell/releases/9184057'
        $release.HtmlUrl | Should -Be 'https://github.com/PowerShell/PowerShell/releases/tag/v6.0.0'
        $release.PreRelease | Should -BeFalse
        $release.Published | Should -Be '01/20/2018 00:19:22'
        $release.Description.Length | Should -Be 3693
        # assets
        $release.Assets.Count | Should -Be 17
        $release.Assets[0].Name | Should -Be 'powershell-6.0.0-1.rhel.7.x86_64.rpm'
        $release.Assets[0].Url | Should -Be 'https://api.github.com/repos/PowerShell/PowerShell/releases/assets/5834075'
        $release.Assets[0].Label | Should -Be ''
        $release.Assets[0].Created | Should -Be '01/10/2018 18:28:40'
        $release.Assets[0].Size | Should -Be 51507206
        $release.Assets[0].DownloadUrl | Should -Be 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell-6.0.0-1.rhel.7.x86_64.rpm'
    }

}