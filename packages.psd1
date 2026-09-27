# ---------------------------------------------------------------------------
#  Everything the setup installs. Add or remove lines here - the scripts
#  read this file, you should never need to touch them to change the app list.
#
#  Chocolatey entries:
#    Id      - Chocolatey package id (find ids with `choco search <name>` or
#              https://community.chocolatey.org/packages)
#    Name    - Friendly name for the summary
#    Params  - Optional package parameters (--package-parameters)
#    Manual  - Optional reminder added to the "manual steps" list after install
# ---------------------------------------------------------------------------
@{
    Chocolatey = @(
        # --- Shell & terminal (needed by the later steps, keep these first) ---
        @{ Id = 'powershell-core';            Name = 'PowerShell 7' }
        @{ Id = 'microsoft-windows-terminal'; Name = 'Windows Terminal' }
        @{ Id = 'oh-my-posh';                 Name = 'Oh My Posh' }
        @{ Id = 'fzf';                        Name = 'fzf' }
        @{ Id = 'git';                        Name = 'Git';     Manual = 'Create SSH keys (ssh-keygen -t ed25519) and add them to GitHub.' }

        # --- Development ---
        @{ Id = 'vscode';         Name = 'VS Code';        Params = '/NoDesktopIcon'; Manual = 'Sign in to Settings Sync to restore extensions and settings.' }
        @{ Id = 'sublimetext4';   Name = 'Sublime Text';   Manual = 'Enter your license key (Help > Enter License).' }
        @{ Id = 'nodejs-lts';     Name = 'Node.js + npm (LTS)' }
        @{ Id = 'dotnet-sdk';     Name = '.NET SDK' }
        @{ Id = 'python';         Name = 'Python 3' }
        @{ Id = 'docker-desktop'; Name = 'Docker Desktop'; Manual = 'Start Docker Desktop after the reboot, accept the terms, sign in, and enable WSL integration for Ubuntu (Settings > Resources > WSL integration).' }
        # JetBrains Toolbox gives you Rider/WebStorm (the profile has `rider` and `ws` aliases). Uncomment if wanted:
        # @{ Id = 'jetbrainstoolbox'; Name = 'JetBrains Toolbox'; Manual = 'Sign in to Toolbox and install Rider and WebStorm.' }

        # --- Everyday apps ---
        @{ Id = 'firefox';                          Name = 'Firefox';   Manual = 'Sign in to Firefox Sync.' }
        @{ Id = 'spotify';                          Name = 'Spotify';   Manual = 'Sign in to Spotify. (If the install failed: Spotify refuses to install as admin - run "winget install Spotify.Spotify" in a normal, non-admin terminal.)' }
        @{ Id = 'microsoft-teams-new-bootstrapper'; Name = 'Microsoft Teams'; Manual = 'Sign in to Teams.' }
        @{ Id = 'slack';                            Name = 'Slack';     Manual = 'Sign in to your Slack workspaces.' }
        @{ Id = 'discord';                          Name = 'Discord';   Manual = 'Sign in to Discord.' }
        @{ Id = 'obsidian';                         Name = 'Obsidian';  Manual = 'Open your vault (or set up Obsidian Sync). Obsidian settings/plugins live inside the vault''s .obsidian folder.' }
        @{ Id = 'steam';                            Name = 'Steam';     Manual = 'Sign in to Steam and choose a library folder.' }
        @{ Id = 'powertoys';                        Name = 'PowerToys'; Manual = 'Restore PowerToys settings: Settings > General > Backup & restore.' }
        @{ Id = 'vlc';                              Name = 'VLC' }
    )

    # Installed into PowerShell 7 for the current user.
    PowerShellModules = @(
        @{ Name = 'PSReadLine'; AlwaysUpdate = $true; SkipPublisherCheck = $true }  # ships with pwsh, but we want the newest
        @{ Name = 'Terminal-Icons' }
        @{ Name = 'posh-git' }
        @{ Name = 'z' }
        @{ Name = 'PSFzf' }
    )

    # `npm install --global` after Node is in place, e.g. 'typescript', 'pnpm'.
    # Empty = the Npm step does nothing.
    NpmGlobal = @(
    )

    # Font installed with `oh-my-posh font install <name>`. CascadiaCode = "CaskaydiaCove NF".
    NerdFont = 'CascadiaCode'

    # Distro installed with `wsl --install -d <name>`. See `wsl --list --online`.
    WslDistro = 'Ubuntu-22.04'
}
