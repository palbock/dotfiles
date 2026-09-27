# Step 2: install every Chocolatey package listed in packages.psd1.
Write-Step 'Applications (Chocolatey)'

if (-not (Test-Command 'choco')) { throw 'choco not found - the Chocolatey step has to succeed first.' }

# Already-installed packages (Chocolatey v2: `choco list` = local packages, "id|version").
$installedPkgs = @{}
foreach ($line in (& choco list --limit-output)) {
    $parts = $line -split '\|'
    if ($parts.Count -ge 2) { $installedPkgs[$parts[0].ToLower()] = $parts[1] }
}

$pkgList = @($Packages.Chocolatey)
$pkgIndex = 0
foreach ($pkg in $pkgList) {
    $pkgIndex++
    $label = "[$pkgIndex/$($pkgList.Count)] $($pkg.Name) ($($pkg.Id))"

    if ($installedPkgs.ContainsKey($pkg.Id.ToLower())) {
        Write-Ok "$label already installed (v$($installedPkgs[$pkg.Id.ToLower()]))"
        Add-Result 'Apps' $pkg.Name 'Skipped' 'Already installed'
        continue
    }

    # Windows 11 ships Windows Terminal from the Store - no need for a second copy.
    if ($pkg.Id -eq 'microsoft-windows-terminal' -and (Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue)) {
        Write-Ok "$label already present (Store version)"
        Add-Result 'Apps' $pkg.Name 'Skipped' 'Store version already present'
        continue
    }

    Write-Info "$label installing..."
    $chocoArgs = @('install', $pkg.Id, '--yes', '--no-progress')
    if ($pkg.Params) { $chocoArgs += "--package-parameters=$($pkg.Params)" }
    & choco @chocoArgs | Out-Host
    $code = $LASTEXITCODE

    if ($code -eq 0 -or $code -eq 1641 -or $code -eq 3010) {
        $note = ''
        if ($code -ne 0) { $script:RebootRequired = $true; $note = 'Reboot required' }
        Write-Ok "$label installed"
        Add-Result 'Apps' $pkg.Name 'Installed' $note
        if ($pkg.Manual) { Add-ManualStep "$($pkg.Name): $($pkg.Manual)" }
    }
    else {
        Write-Fail "$label failed (choco exit code $code)"
        Add-Result 'Apps' $pkg.Name 'Failed' "choco exit code $code"
        Add-ManualStep "$($pkg.Name): automatic install failed. Try 'choco install $($pkg.Id)' again, or install it from the vendor's website. $($pkg.Manual)"
    }
}

Update-Path
