# This script for internal use only.
# To avoid Nuget.Versioning.dll assembly load conflict, we call this script as a job (as a external process).
param ([string]$Query)

# Load assembly
Add-Type -AssemblyName './NuGet.Versioning.dll'

$output = [pscustomobject]@{
    Result           = $false
    MinVersionString = $null
    IsMinInclusive   = $true
    MaxVersionString = $null
    IsMaxInclusive   = $true
    VerboseLogs      = [System.Collections.Generic.List[string]]::new()
}
$output.VerboseLogs.Add("Parameters : Query = $($Query), WorkingDirectory = $($pwd.Path)")
$output.VerboseLogs.Add("Loaded Assembly : $([NuGet.Versioning.VersionRange].Assembly.FullName)")
$output.VerboseLogs.Add("Assembly Location : $([NuGet.Versioning.VersionRange].Assembly.Location)")

# early return
$Query = $Query.Trim()
if ([string]::IsNullOrEmpty($Query)) {
    $output.Result = $true
    return $output
}
if ($Query -eq '*') {
    $output.Result = $true
    return $output
}

# try parse single version
# ref : https://docs.microsoft.com/ja-jp/nuget/concepts/package-versioning#version-ranges
$parsedVer = $null
if ([semver]::TryParse($Query, [ref]$parsedVer)) {
    $output.Result = $true
    $output.MinVersionString = $parsedVer.ToString()
    return $output
}

# try parse range version
$parsedVer = $null
if ([NuGet.Versioning.VersionRange]::TryParse($Query, [ref]$parsedVer)) {
    $output.Result = $true
    $output.VerboseLogs.Add("Parsed value : IsMinInclusive = $($parsedVer.IsMinInclusive), IsMaxInclusive = $($parsedVer.IsMaxInclusive)")
    $output.MinVersionString = $(if ($parsedVer.MinVersion) { $parsedVer.MinVersion.ToFullString() }else { $null })
    $output.IsMinInclusive = $parsedVer.IsMinInclusive
    $output.MaxVersionString = $(if ($parsedVer.MaxVersion) { $parsedVer.MaxVersion.ToFullString() }else { $null })
    $output.IsMaxInclusive = $parsedVer.IsMaxInclusive
    return $output
}

# faled parse
return $output
