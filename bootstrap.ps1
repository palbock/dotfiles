<#
.SYNOPSIS
    Downloads this repository to %USERPROFILE%\dotfiles and starts the setup.
.DESCRIPTION
    Meant for a brand new machine where Git is not installed yet. Run it from any
    PowerShell window:

        Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/YOUR-GITHUB-USER/dotfiles/main/bootstrap.ps1 | iex

    Edit $Repo below after you push the repository to GitHub.
#>

$Repo   = 'YOUR-GITHUB-USER/dotfiles'   # <-- change me
$Branch = 'main'
$Dest   = Join-Path $env:USERPROFILE 'dotfiles'

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # makes Invoke-WebRequest much faster on Windows PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$zip   = Join-Path $env:TEMP "dotfiles-$stamp.zip"
$tmp   = Join-Path $env:TEMP "dotfiles-$stamp"

Write-Host "Downloading $Repo ($Branch)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip -UseBasicParsing

Expand-Archive -Path $zip -DestinationPath $tmp -Force
$inner = Get-ChildItem -Path $tmp -Directory | Select-Object -First 1

if (Test-Path $Dest) {
    Write-Host "Existing $Dest found - renaming it to dotfiles.bak-$stamp" -ForegroundColor Yellow
    Rename-Item -Path $Dest -NewName "dotfiles.bak-$stamp"
}
Move-Item -Path $inner.FullName -Destination $Dest
Get-ChildItem -Path $Dest -Recurse -File | Unblock-File
Remove-Item $zip, $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Repository is in $Dest - starting setup..." -ForegroundColor Cyan
& (Join-Path $Dest 'setup.cmd')
