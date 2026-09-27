# Step 7: WSL 2 + Ubuntu. Runs last because the first run needs a reboot;
# setup.ps1 schedules itself to resume after the restart and then installs the distro.
Write-Step 'WSL'

$env:WSL_UTF8 = '1'   # make wsl.exe print UTF-8 instead of UTF-16
$distro = $Packages.WslDistro

$vmpState  = (Get-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform' -ErrorAction SilentlyContinue).State
$null      = & wsl.exe --version 2>&1   # fails on the old inbox wsl.exe / before WSL is installed
$wslCoreOk = ($LASTEXITCODE -eq 0)

if ("$vmpState" -ne 'Enabled' -or -not $wslCoreOk) {
    Write-Info 'Installing the WSL platform (distro comes after the reboot)...'
    & wsl.exe --install --no-distribution | Out-Host
    if ($LASTEXITCODE -eq 0) {
        $script:RebootRequired = $true
        Write-Warn "Reboot required. Setup resumes automatically afterwards and installs $distro."
        Add-Result 'WSL' 'WSL platform' 'Installed' 'Reboot required'
    }
    else {
        Write-Fail "wsl --install failed (exit code $LASTEXITCODE)"
        Add-Result 'WSL' 'WSL platform' 'Failed' "exit code $LASTEXITCODE"
        Add-ManualStep "WSL: run 'wsl --install' in an admin terminal, reboot, then run setup.cmd again. Virtualization must be enabled in BIOS/UEFI."
    }
    return
}

$distros = @(& wsl.exe --list --quiet 2>$null | ForEach-Object { ($_ -replace "`0", '').Trim() } | Where-Object { $_ })
if ($distros -contains $distro) {
    Write-Ok "$distro already installed"
    Add-Result 'WSL' $distro 'Skipped' 'Already installed'
    return
}

Write-Info "Installing $distro..."
& wsl.exe --install --distribution $distro --no-launch | Out-Host
if ($LASTEXITCODE -eq 0) {
    Write-Ok "$distro installed"
    Add-Result 'WSL' $distro 'Installed'
    Add-ManualStep "WSL: open '$distro' from the Start menu (or run 'wsl -d $distro') once to create your Linux username and password, then run 'sudo apt update && sudo apt upgrade -y'."
}
else {
    Write-Fail "$distro install failed (exit code $LASTEXITCODE)"
    Add-Result 'WSL' $distro 'Failed' "exit code $LASTEXITCODE"
    Add-ManualStep "WSL: run 'wsl --install -d $distro' manually."
}
