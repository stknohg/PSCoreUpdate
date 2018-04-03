# import module
$RootPath = Join-Path $PSScriptRoot 'PSCoreUpdate'
Import-Module (Join-Path $RootPath 'PSCoreUpdate.psd1') -Force

# invoke all tests
$TestRootPath = Join-Path $PSScriptRoot 'PSCoreUpdate.Tests'
$TestOutputPath = '.\TestsResults.xml'
$result = Invoke-Pester -Path $TestRootPath -OutputFormat NUnitXml -OutputFile $TestOutputPath -PassThru
if ($null -ne $env:APPVEYOR_JOB_ID) {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $TestOutputPath))
}
if ($result.FailedCount -gt 0) { 
    throw "$($result.FailedCount) tests failed."
}
