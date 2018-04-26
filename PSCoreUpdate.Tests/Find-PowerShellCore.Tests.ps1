$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Find-PowerShellCore unit tests" {

    BeforeAll {
        $Token = $env:GITHUB_ACCESS_TOKEN
        if ([string]::IsNullOrEmpty($Token)) {
            Write-Host 'GITHUB_ACCESS_TOKEN is empty.'
        }
    }

    It "Returns nothing when specified invalid version" {
        Find-PowerShellCore -MinimumVersion 999.0.0 -Token $Token | Should -BeNullOrEmpty
        Find-PowerShellCore -MaximumVersion 0.0.1 -Token $Token | Should -BeNullOrEmpty
    }

    It "Should exclude prerelease version with -ExcludePreRelease parameter" {
        Find-PowerShellCore -Version 6.0.0-alpha.18 -ExcludePreRelease -Token $Token | Should -BeNullOrEmpty
        Find-PowerShellCore -Version 6.0.0-beta.1 -ExcludePreRelease -Token $Token | Should -BeNullOrEmpty
        Find-PowerShellCore -Version 6.0.0-rc.1 -ExcludePreRelease -Token $Token | Should -BeNullOrEmpty
    }

    It "Should get the latest release information" {
        Find-PowerShellCore -Latest -Token $Token | Should -Not -BeNullOrEmpty
        $release = Find-PowerShellCore -Latest -Token $Token 
        $release.Count | Should -Be 1
    }

    It "Should get the latest release with -ExcludePreRelease parameter" {
        $target = Find-PowerShellCore -Latest -ExcludePreRelease -Token $Token
        $expected = Find-PowerShellCore -MinimumVersion 6.0.0 -Token $Token | 
            Where-Object { -not $_.PreRelease } |
            Sort-Object -Property Version -Top 1 -Descending
        $target.Version | Should -Be $expected.Version
    }

    It "Should get the range releases information(specify MinimumVersion)" {
        $release = Find-PowerShellCore -MinimumVersion '6.0.0' -Token $Token
        $release.Count | Should -BeGreaterThan 1
        $release = Find-PowerShellCore -ExcludePreRelease -MinimumVersion '6.0.0' -Token $Token
        $release.Count | Should -BeGreaterThan 1
    }

    It "Should get the range releases information(specify MaximumVersion)" {
        $release = Find-PowerShellCore -MaximumVersion '6.0.0' -Token $Token
        $release.Count | Should -Be 30
        $release = Find-PowerShellCore -ExcludePreRelease -MaximumVersion '6.0.0' -Token $Token
        $release.Count | Should -Be 1
    }

    It "Should get the range releases information(specify MinimumVersion, MaximumVersion)" {
        $release = Find-PowerShellCore -MinimumVersion '6.0.0' -MaximumVersion '6.0.1' -Token $Token
        $release.Count | Should -Be 2
        $release = Find-PowerShellCore -ExcludePreRelease -MinimumVersion '6.0.0' -MaximumVersion '6.0.1' -Token $Token
        $release.Count | Should -Be 2
    }

    It "Should get proper properties" {
        $release = Find-PowerShellCore -Version 6.0.0 -Token $Token
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