#!/usr/bin/env powershell

#Requires -Version 5

param (
    # The name of the component to be built. Defaults to none
    [string]$Component,
    # The base hab version to run the build with. Defaults to latest
    [string]$BaseHabVersion="latest",
    # The builder channel to pull from. Defaults to stable
    [string]$SourceChannel="stable"
)

# Import shared functions
. "$PSScriptRoot\shared.ps1" -ErrorAction Stop

if($Component.Equals("")) {
    Write-Error "--- :error: Component to build not specified, please use the -Component flag" -ErrorAction Stop
}

Write-Host "--- Setting source package channel to $SourceChannel"
$Env:HAB_BLDR_CHANNEL="$SourceChannel"

# install buildkite agent because we are in a container :(
Write-Host "--- Installing buildkite agent in container"
$Env:buildkiteAgentToken = $Env:BUILDKITE_AGENT_ACCESS_TOKEN
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/buildkite/agent/master/install.ps1'))    
    
Write-Host "--- Installing base habitat binary version: $BaseHabVersion"
$baseHabExe = [HabShared]::install_base_habitat_binary($BaseHabVersion, $SourceChannel)
Write-Host "--- Using hab executable at $baseHabExe"

Write-Host "--- Importing Keys"
[HabShared]::import_keys($baseHabExe)

Write-Host "--- Moving build folder to new location"
New-Item -ItemType directory -Path C:\build
Copy-Item -Path C:\workdir\* -Destination C:\build -Recurse

Push-Location "C:\build"
    Write-Host "--- Running hab pkg build for $Component"
    Invoke-Expression "$baseHabExe pkg build components\$Component --keys core" -ErrorAction Stop
    . "components\$Component\habitat\results\last_build.ps1"
    Write-Host "Running hab pkg upload for $Component"
    Invoke-Expression "$baseHabExe pkg upload components\$Component\habitat\results\$pkg_artifact" -ErrorAction Stop

    If ($Component -eq 'hab') {
        Write-Host "--- :buildkite: Recording metadata $pkg_ident"
        Invoke-Expression "buildkite-agent meta-data set 'hab-version' '$pkg_ident'"
        Invoke-Expression "buildkite-agent meta-data set 'hab-release-windows' '$pkg_release'"
        Invoke-Expression "buildkite-agent meta-data set 'hab-artifact-windows' '$pkg_artifact'"
    } Elseif ($component -eq 'studio') {
        Write-Host "--- :buildkite: Recording metadata for $pkg_ident"
        Invoke-Expression "buildkite-agent meta-data set 'studio-version-windows' $pkg_ident"       
    } Else {
        Write-Host "Not recording any metadata for $pkg_ident, none required."
    } 
Pop-Location

exit $LASTEXITCODE