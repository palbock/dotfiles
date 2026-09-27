# ============================================================================
#  PowerShell 7 profile
#  Lives in the dotfiles repo: config/powershell/Microsoft.PowerShell_profile.ps1
#  Edit it with `code $PROFILE`, then run scripts/export-config.ps1 to save it.
# ============================================================================

# ---------- Prompt ----------------------------------------------------------
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config 'C:/Prompt/microverse-power.json' | Invoke-Expression
}

# ---------- Modules ---------------------------------------------------------
foreach ($module in 'PSReadLine', 'Terminal-Icons', 'posh-git', 'z') {
    try   { Import-Module $module -ErrorAction Stop }
    catch { Write-Warning "Module '$module' is not installed. Run: Install-Module $module -Scope CurrentUser" }
}
$env:POSH_GIT_ENABLED = $true

# ---------- PSReadLine ------------------------------------------------------
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# ---------- fzf (Ctrl+T = fuzzy file search, Ctrl+R = fuzzy history) --------
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

Set-ExecutionPolicy Bypass -Scope Process -Force

# ---------- Helpers ---------------------------------------------------------
# Starts a program if it exists, passing paths through as full, quoted paths.
function Start-App {
    param([string]$Path, [string[]]$Arguments)
    if (-not (Test-Path $Path)) { Write-Warning "Not found: $Path"; return }
    if ($Arguments) {
        $quoted = foreach ($a in $Arguments) {
            if (Test-Path $a) { $a = (Resolve-Path $a).Path }
            "`"$a`""
        }
        Start-Process -FilePath $Path -ArgumentList $quoted
    }
    else {
        Start-Process -FilePath $Path
    }
}

function openGoogle    { Start-Process 'https://www.google.com' }
function openSublime   { Start-App "$env:ProgramFiles\Sublime Text\subl.exe" $args }
function startRider    { Start-App "$env:LOCALAPPDATA\Programs\Rider\bin\rider64.exe" $args }
function startWebstorm { Start-App "$env:LOCALAPPDATA\Programs\WebStorm\bin\webstorm64.exe" $args }

Set-Alias google openGoogle
Set-Alias subl   openSublime
Set-Alias rider  startRider
Set-Alias ws     startWebstorm

# ---------- Chocolatey tab completion ---------------------------------------
# See https://ch0.co/tab-completion
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module "$ChocolateyProfile"
}
