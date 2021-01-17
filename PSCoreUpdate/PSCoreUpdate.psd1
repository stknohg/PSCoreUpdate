@{
    ModuleVersion        = '3.0.0'
    CompatiblePSEditions = @('Core')
    GUID                 = '043f72a6-8b4c-49d2-b23e-c670121378fb'
    Author               = 'Takuya Shibata'
    CompanyName          = 'Takuya Shibata'
    Copyright            = '(c) Takuya Shibata. All rights reserved.'
    Description          = 'PowerShell Core update tool'
    PowerShellVersion    = '6.0.0'
    RequiredAssemblies   = @("NuGet.Versioning.dll")
    TypesToProcess       = @('PSCoreUpdate.types.ps1xml')
    FormatsToProcess     = @('PSCoreUpdate.format.ps1xml')
    NestedModules        = @('PSCoreUpdate.psm1')
    FunctionsToExport    = @('Find-PowerShellBuildStatus', 'Find-PowerShellRelease', 
                             'Get-PowerShellGitHubApiToken', 'Remove-PowerShellGitHubApiToken', 'Save-PowerShellAsset', 'Set-PowerShellGitHubApiToken',
                             'Test-LatestVersion', 'Update-PowerShellRelease', 
                             'Enable-PSCoreUpdateLegacyAlias')
    CmdletsToExport      = @()
    VariablesToExport    = '*'
    AliasesToExport      = @('Download-PowerShellAsset')
    PrivateData          = @{
        PSData = @{
            Prerelease = 'beta2'
            LicenseUri = 'https://github.com/stknohg/PSCoreUpdate/blob/master/LICENSE'
            ProjectUri = 'https://github.com/stknohg/PSCoreUpdate'
        }
    }

}