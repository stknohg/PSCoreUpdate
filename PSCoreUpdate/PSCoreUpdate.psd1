@{
    ModuleVersion        = '3.0.0'
    CompatiblePSEditions = @('Core')
    GUID                 = '043f72a6-8b4c-49d2-b23e-c670121378fb'
    Author               = 'Takuya Shibata'
    CompanyName          = 'Takuya Shibata'
    Copyright            = '(c) Takuya Shibata. All rights reserved.'
    Description          = 'PowerShell Core update tool'
    PowerShellVersion    = '7.0.0'
    TypesToProcess       = @('PSCoreUpdate.types.ps1xml')
    FormatsToProcess     = @('PSCoreUpdate.format.ps1xml')
    NestedModules        = @('PSCoreUpdate.psm1')
    FunctionsToExport    = @('Find-PowerShellBuildStatus', 'Find-PowerShellRelease', 
                             'Test-LatestVersion', 'Update-PowerShellRelease', 'Save-PowerShellAsset', 
                             'Get-PowerShellGitHubApiToken', 'Remove-PowerShellGitHubApiToken', 'Set-PowerShellGitHubApiToken',
                             'Enable-PSCoreUpdateLegacyAlias')
    CmdletsToExport      = @()
    VariablesToExport    = '*'
    AliasesToExport      = @('Download-PowerShellAsset')
    PrivateData          = @{
        PSData = @{
            Prerelease = 'beta4'
            LicenseUri = 'https://github.com/stknohg/PSCoreUpdate/blob/master/LICENSE'
            ProjectUri = 'https://github.com/stknohg/PSCoreUpdate'
        }
    }

}