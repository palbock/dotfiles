# Step 6: global npm packages listed in packages.psd1 (empty by default).
Write-Step 'Global npm packages'

if (-not $Packages.NpmGlobal) { Write-Info 'None configured'; return }

Update-Path
if (-not (Test-Command 'npm.cmd')) {
    Write-Fail 'npm not found'
    Add-Result 'Npm' ($Packages.NpmGlobal -join ', ') 'Failed' 'npm not on PATH'
    Add-ManualStep "npm: open a new terminal and run: npm install --global $($Packages.NpmGlobal -join ' ')"
    return
}

foreach ($npmPkg in $Packages.NpmGlobal) {
    Write-Info "npm install --global $npmPkg"
    & npm.cmd install --global $npmPkg | Out-Host
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$npmPkg installed"
        Add-Result 'Npm' $npmPkg 'Installed'
    }
    else {
        Write-Fail "$npmPkg failed (exit code $LASTEXITCODE)"
        Add-Result 'Npm' $npmPkg 'Failed' "exit code $LASTEXITCODE"
        Add-ManualStep "npm: run 'npm install --global $npmPkg' in a new terminal."
    }
}
