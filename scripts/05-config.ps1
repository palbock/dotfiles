# Step 5: copy dotfiles into place (oh-my-posh theme, PowerShell profile, Windows Terminal settings).
Write-Step 'Configuration files'

$configDir = Join-Path $Root 'config'
$promptDir = 'C:\Prompt'   # referenced by the PowerShell profile

# oh-my-posh theme -> C:\Prompt
Install-ConfigFile -Source (Join-Path $configDir 'oh-my-posh\microverse-power.json') `
                   -Destination (Join-Path $promptDir 'microverse-power.json') -Label 'oh-my-posh theme'

# PowerShell 7 profile. MyDocuments respects OneDrive folder redirection.
$docs = [Environment]::GetFolderPath('MyDocuments')
Install-ConfigFile -Source (Join-Path $configDir 'powershell\Microsoft.PowerShell_profile.ps1') `
                   -Destination (Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1') -Label 'PowerShell profile'

# Global git config. Identity goes in ~/.gitconfig.local (included by .gitconfig),
# so re-running setup never clobbers your name/email.
Install-ConfigFile -Source (Join-Path $configDir 'git\.gitconfig') `
                   -Destination (Join-Path $env:USERPROFILE '.gitconfig') -Label 'Git config'
$gitLocal = Join-Path $env:USERPROFILE '.gitconfig.local'
if (-not (Test-Path $gitLocal)) {
    Set-Content -Path $gitLocal -Encoding ASCII -Value @(
        '# Machine-specific git settings (not in the dotfiles repo).',
        '# git config --file ~/.gitconfig.local user.name  "Your Name"',
        '# git config --file ~/.gitconfig.local user.email "you@example.com"'
    )
    Write-Ok ".gitconfig.local created at $gitLocal"
}
if (-not (Get-Content $gitLocal | Where-Object { $_ -match '^\s*(name|email)\s*=' })) {
    Add-ManualStep 'Git: set your identity: git config --file ~/.gitconfig.local user.name "Your Name" and git config --file ~/.gitconfig.local user.email "you@example.com"'
}

# Windows Terminal: Store/MSIX build and/or the unpackaged build.
$wtSource  = Join-Path $configDir 'terminal\settings.json'
$wtTargets = @()
if (Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue) {
    $wtTargets += Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
}
$wtUnpackaged = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal'
if (Test-Path $wtUnpackaged) { $wtTargets += Join-Path $wtUnpackaged 'settings.json' }

if ($wtTargets.Count -eq 0) {
    Write-Fail 'Windows Terminal not found'
    Add-Result 'Config' 'Windows Terminal settings' 'Failed' 'Windows Terminal not installed'
    Add-ManualStep 'Windows Terminal: install it, then open Settings > "Open JSON file" and paste config\terminal\settings.json.'
}
foreach ($target in $wtTargets) {
    Install-ConfigFile -Source $wtSource -Destination $target -Label 'Windows Terminal settings'
}
