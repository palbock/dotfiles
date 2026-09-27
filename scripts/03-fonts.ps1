# Step 3: CaskaydiaCove Nerd Font (used by Windows Terminal and the oh-my-posh theme).
Write-Step 'Nerd Font (CaskaydiaCove NF)'

$fontKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
    'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
)
$hasFont = $false
foreach ($key in $fontKeys) {
    if ((Test-Path $key) -and ((Get-Item $key).Property -match 'Caskaydia')) { $hasFont = $true }
}

if ($hasFont) {
    Write-Ok 'CaskaydiaCove Nerd Font already installed'
    Add-Result 'Fonts' 'CaskaydiaCove NF' 'Skipped' 'Already installed'
}
elseif (-not (Test-Command 'oh-my-posh')) {
    Write-Fail 'oh-my-posh not found, cannot install the font automatically'
    Add-Result 'Fonts' 'CaskaydiaCove NF' 'Failed' 'oh-my-posh missing'
    Add-ManualStep 'Font: download "CascadiaCode" from https://www.nerdfonts.com/font-downloads, select all .ttf files > right-click > Install for all users.'
}
else {
    Write-Info "Installing $($Packages.NerdFont) Nerd Font for all users..."
    & oh-my-posh font install $Packages.NerdFont | Out-Host
    if ($LASTEXITCODE -eq 0) {
        Write-Ok 'CaskaydiaCove Nerd Font installed'
        Add-Result 'Fonts' 'CaskaydiaCove NF' 'Installed'
    }
    else {
        Write-Fail "oh-my-posh font install failed (exit code $LASTEXITCODE)"
        Add-Result 'Fonts' 'CaskaydiaCove NF' 'Failed' "exit code $LASTEXITCODE"
        Add-ManualStep 'Font: download "CascadiaCode" from https://www.nerdfonts.com/font-downloads, select all .ttf files > right-click > Install for all users.'
    }
}
