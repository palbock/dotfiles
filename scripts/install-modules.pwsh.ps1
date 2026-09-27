#Requires -Version 7
# Installs the PowerShell modules from packages.psd1 for the current user.
# Called by setup (step 4) but also fine to run by hand from pwsh.
# Exit code = number of modules that failed.

$ErrorActionPreference = 'Stop'
$root     = Split-Path $PSScriptRoot -Parent
$packages = Import-PowerShellDataFile (Join-Path $root 'packages.psd1')
$failed   = 0

try {
    if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
    }
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
}
catch { Write-Warning "PSGallery preparation: $($_.Exception.Message)" }

foreach ($module in $packages.PowerShellModules) {
    $present = Get-Module -ListAvailable -Name $module.Name | Sort-Object Version -Descending | Select-Object -First 1
    if ($present -and -not $module.AlwaysUpdate) {
        Write-Host "    [ok]   $($module.Name) $($present.Version) already installed" -ForegroundColor Green
        continue
    }
    try {
        $params = @{ Name = $module.Name; Scope = 'CurrentUser'; Force = $true; AllowClobber = $true }
        if ($module.SkipPublisherCheck) { $params.SkipPublisherCheck = $true }
        Install-Module @params
        Write-Host "    [ok]   $($module.Name) installed" -ForegroundColor Green
    }
    catch {
        Write-Host "    [fail] $($module.Name): $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

exit $failed
