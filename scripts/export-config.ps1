<#
.SYNOPSIS
    Copies the config currently in use on this machine back into the repo,
    so you can commit changes you made (new aliases, terminal tweaks, ...).
.EXAMPLE
    .\scripts\export-config.ps1; git diff
#>
$root = Split-Path $PSScriptRoot -Parent
$docs = [Environment]::GetFolderPath('MyDocuments')

$wtPackaged   = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$wtUnpackaged = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'
$wtSettings   = if (Test-Path $wtPackaged) { $wtPackaged } else { $wtUnpackaged }

$map = [ordered]@{
    (Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1') = 'config\powershell\Microsoft.PowerShell_profile.ps1'
    'C:\Prompt\microverse-power.json'                               = 'config\oh-my-posh\microverse-power.json'
    $wtSettings                                                     = 'config\terminal\settings.json'
    (Join-Path $env:USERPROFILE '.gitconfig')                       = 'config\git\.gitconfig'
}

foreach ($source in $map.Keys) {
    $dest = Join-Path $root $map[$source]
    if (Test-Path $source) {
        New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "  [ok]   $source -> $($map[$source])" -ForegroundColor Green
    }
    else {
        Write-Host "  [skip] $source (not found)" -ForegroundColor Yellow
    }
}
Write-Host "`nNow review with 'git diff' and commit." -ForegroundColor Cyan
