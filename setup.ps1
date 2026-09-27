<#
.SYNOPSIS
    One-shot setup for a new Windows machine.
.DESCRIPTION
    Installs Chocolatey, then every app in packages.psd1, the Nerd Font, the
    PowerShell modules, copies the dotfiles into place and installs WSL.

    Safe to run as many times as you like: anything already installed or
    already up to date is skipped. Start it with setup.cmd (double-click) or
    bootstrap.ps1 (one-liner from GitHub). It elevates itself.
.PARAMETER Skip
    Steps to skip, comma separated:
    Chocolatey, Apps, Fonts, PowerShellModules, Config, Npm, WSL
.PARAMETER NoReboot
    Never offer a restart and never schedule the automatic resume.
.EXAMPLE
    setup.cmd -Skip WSL,Npm
#>
[CmdletBinding()]
param(
    [string[]]$Skip = @(),
    [switch]$NoReboot
)

$ErrorActionPreference = 'Continue'

$AllSteps = [ordered]@{
    Chocolatey        = '01-chocolatey.ps1'
    Apps              = '02-apps.ps1'
    Fonts             = '03-fonts.ps1'
    PowerShellModules = '04-powershell-modules.ps1'
    Config            = '05-config.ps1'
    Npm               = '06-npm.ps1'
    WSL               = '07-wsl.ps1'
}

# setup.cmd passes "-Skip WSL,Npm" as one string, so split it ourselves.
$Skip = @($Skip | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$unknown = @($Skip | Where-Object { $AllSteps.Keys -notcontains $_ })
if ($unknown.Count) {
    Write-Host "Unknown step(s) in -Skip: $($unknown -join ', ')" -ForegroundColor Red
    Write-Host "Valid steps: $($AllSteps.Keys -join ', ')"
    exit 1
}

# --- Elevate, and always run the orchestration in Windows PowerShell 5.1 ----
# (Windows PowerShell is the one shell guaranteed to exist on a fresh install,
#  and Appx/optional-feature cmdlets behave best there.)
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin   = ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isDesktop = $PSVersionTable.PSEdition -ne 'Core'

if (-not $isAdmin -or -not $isDesktop) {
    Write-Host 'Relaunching in an elevated Windows PowerShell window...' -ForegroundColor Yellow
    $argLine = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($Skip.Count) { $argLine += " -Skip $($Skip -join ',')" }
    if ($NoReboot)   { $argLine += ' -NoReboot' }
    $startArgs = @{ FilePath = 'powershell.exe'; ArgumentList = $argLine }
    if (-not $isAdmin) { $startArgs.Verb = 'RunAs' }
    Start-Process @startArgs
    exit
}

# --- Main -------------------------------------------------------------------
$Root   = $PSScriptRoot
$LogDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
Start-Transcript -Path (Join-Path $LogDir "setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log") | Out-Null

. (Join-Path $Root 'scripts\common.ps1')
$Packages = Import-PowerShellDataFile -Path (Join-Path $Root 'packages.psd1')

Write-Banner

foreach ($stepName in $AllSteps.Keys) {
    if ($Skip -contains $stepName) {
        Write-Step "$stepName (skipped with -Skip)"
        Add-Result $stepName '-' 'Skipped' 'Skipped with -Skip'
        continue
    }
    try {
        . (Join-Path $Root "scripts\$($AllSteps[$stepName])")
    }
    catch {
        Write-Fail "Step '$stepName' crashed: $($_.Exception.Message)"
        Add-Result $stepName '-' 'Failed' $_.Exception.Message
    }
}

Write-Summary

if ($script:RebootRequired -and -not $NoReboot) {
    # Resume automatically after the restart (installs the WSL distro etc.).
    $runOnce = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    Set-ItemProperty -Path $runOnce -Name 'DevMachineSetup' -Value "cmd.exe /c `"`"$Root\setup.cmd`"`""
    Write-Warn 'A restart is required. Setup will continue automatically after you log back in.'
    $answer = Read-Host 'Restart now? [Y/n]'
    Stop-Transcript | Out-Null
    if ($answer -notmatch '^(n|no)$') { Restart-Computer -Force }
    exit
}

Stop-Transcript | Out-Null
Read-Host 'Done. Press Enter to close this window'
