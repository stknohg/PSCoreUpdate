$RootPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

Describe "Test-LatestVersion unit tests" {

    It "Test-LatestVersion exit normaly" {
        { Test-LatestVersion } | Should -Not -Throw
    }

    It "Test-LatestVersion -PassThru returns a result object" {
        $result = Test-LatestVersion -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Result | Should -BeOfType 'bool'
        if ($result.Result) {
            $result.Release | Should -BeNullOrEmpty
        } else {
            $result.Release | Should -Not -BeNullOrEmpty
        }
    }
}