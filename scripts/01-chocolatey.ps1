# Step 1: Chocolatey - everything else is installed through it.
Write-Step 'Chocolatey'

if (Test-Command 'choco') {
    Write-Ok "Chocolatey already installed (v$(& choco --version))"
    Add-Result 'Chocolatey' 'chocolatey' 'Skipped' 'Already installed'
}
else {
    Write-Info 'Installing Chocolatey (official install script)...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Update-Path
    if (-not (Test-Command 'choco')) { throw 'Chocolatey installer finished, but choco is not on PATH.' }
    Write-Ok "Chocolatey v$(& choco --version) installed"
    Add-Result 'Chocolatey' 'chocolatey' 'Installed'
}

# No "Are you sure?" prompts for every package.
& choco feature enable --name allowGlobalConfirmation | Out-Null
