@{

    # Version number of this module.
    ModuleVersion        = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID                 = '043f72a6-8b4c-49d2-b23e-c670121378fb'

    # Author of this module
    Author               = 'stknohg'

    # Company or vendor of this module
    CompanyName          = 'stknohg'

    # Copyright statement for this module
    Copyright            = '(c) stknohg. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'PowerShell Core update tool'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '6.0.0'

    # Name of the PowerShell host required by this module
    #PowerShellHostName = 'ConsoleHost'

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @('PSCoreUpdate.format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules        = @('PSCoreUpdate.psm1')

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @('Find-PowerShellCore', 'Save-PowerShellCore', 'Test-LatestVersion', 'Update-PowerShellCore')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @('Download-PowerShellCore')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/stknohg/PSCoreUpdate/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/stknohg/PSCoreUpdate'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''
        }
    }

}

