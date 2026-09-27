# Shared helpers, dot-sourced by setup.ps1. Keep this file ASCII-only:
# Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$script:Results        = New-Object System.Collections.Generic.List[object]
$script:ManualSteps    = New-Object System.Collections.Generic.List[string]
$script:RebootRequired = $false

function Write-Banner {
    Write-Host ''
    Write-Host '  ==============================================' -ForegroundColor Magenta
    Write-Host '     New machine setup' -ForegroundColor Magenta
    Write-Host "     $env:COMPUTERNAME / $env:USERNAME" -ForegroundColor Magenta
    Write-Host '  ==============================================' -ForegroundColor Magenta
}

function Write-Step([string]$Message) { Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Info([string]$Message) { Write-Host "    $Message" -ForegroundColor Gray }
function Write-Ok  ([string]$Message) { Write-Host "    [ok]   $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "    [warn] $Message" -ForegroundColor Yellow }
function Write-Fail([string]$Message) { Write-Host "    [fail] $Message" -ForegroundColor Red }

function Add-Result {
    param(
        [string]$Step,
        [string]$Item,
        [ValidateSet('Installed', 'Configured', 'Skipped', 'Failed')][string]$Status,
        [string]$Note = ''
    )
    $script:Results.Add([pscustomobject]@{ Step = $Step; Item = $Item; Status = $Status; Note = $Note })
}

function Add-ManualStep([string]$Text) {
    if (-not $script:ManualSteps.Contains($Text)) { $script:ManualSteps.Add($Text) }
}

function Test-Command([string]$Name) {
    [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# Reload PATH (and ChocolateyInstall) so freshly installed tools are usable
# in this same session without opening a new window.
function Update-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
    $choco = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
    if ($choco) { $env:ChocolateyInstall = $choco }
}

# Copy a config file from the repo into place. Existing, different files are
# backed up next to the original as <name>.bak-<timestamp>.
function Install-ConfigFile {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label = (Split-Path $Destination -Leaf),
        [string]$Step  = 'Config'
    )
    if (-not (Test-Path $Source)) {
        Write-Fail "$Label - missing from repo: $Source"
        Add-Result $Step $Label 'Failed' 'Source file missing from repo'
        return
    }
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null

    if (Test-Path $Destination) {
        if ((Get-FileHash $Source).Hash -eq (Get-FileHash $Destination).Hash) {
            Write-Ok "$Label already up to date"
            Add-Result $Step $Label 'Skipped' 'Already up to date'
            return
        }
        $backup = "$Destination.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -Path $Destination -Destination $backup -Force
        Write-Info "Backed up existing $Label to $backup"
    }
    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Ok "$Label -> $Destination"
    Add-Result $Step $Label 'Configured' $Destination
}

function Write-Summary {
    Write-Step 'Summary'
    $script:Results | Format-Table -AutoSize -Wrap Step, Item, Status, Note | Out-String -Width 220 | Write-Host

    $failed = @($script:Results | Where-Object { $_.Status -eq 'Failed' })
    if ($failed.Count) {
        Write-Host "  $($failed.Count) item(s) failed. Check the log in $LogDir and simply run setup.cmd again." -ForegroundColor Red
    } else {
        Write-Host '  Everything went through.' -ForegroundColor Green
    }

    if ($script:ManualSteps.Count) {
        Write-Step 'Things you still need to do by hand'
        $lines = @()
        $i = 1
        foreach ($m in $script:ManualSteps) { $lines += "[$i] $m"; $i++ }
        $lines | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }

        $header  = @("Manual steps left after setup ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))", '')
        $targets = @((Join-Path $LogDir 'manual-steps.txt'))
        $desktop = [Environment]::GetFolderPath('Desktop')
        if ($desktop) { $targets += Join-Path $desktop 'setup-todo.txt' }
        foreach ($todo in $targets) {
            ($header + $lines) | Set-Content -Path $todo -Encoding UTF8
            Write-Host "  Saved to $todo" -ForegroundColor Gray
        }
    }
}
