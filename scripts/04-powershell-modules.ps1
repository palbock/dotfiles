# Step 4: PowerShell modules. They must be installed *from PowerShell 7*,
# because pwsh and Windows PowerShell use different module folders.
Write-Step 'PowerShell 7 modules'

$pwshExe = (Get-Command 'pwsh' -ErrorAction SilentlyContinue).Source
if (-not $pwshExe) {
    $candidate = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
    if (Test-Path $candidate) { $pwshExe = $candidate }
}

if (-not $pwshExe) {
    Write-Fail 'PowerShell 7 (pwsh) not found'
    Add-Result 'PowerShellModules' 'modules' 'Failed' 'pwsh not installed'
    Add-ManualStep 'PowerShell modules: install PowerShell 7 (choco install powershell-core), then run scripts\install-modules.pwsh.ps1 from pwsh.'
    return
}

& $pwshExe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root 'scripts\install-modules.pwsh.ps1')
$failedModules = $LASTEXITCODE

if ($failedModules -eq 0) {
    Add-Result 'PowerShellModules' (($Packages.PowerShellModules | ForEach-Object { $_.Name }) -join ', ') 'Configured'
}
else {
    Add-Result 'PowerShellModules' 'modules' 'Failed' "$failedModules module(s) failed"
    Add-ManualStep 'PowerShell modules: some failed - open pwsh and run scripts\install-modules.pwsh.ps1 again to see the error.'
}
