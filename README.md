# 🖥️ dotfiles — my Windows dev machine, in one click

Everything I install and configure on a new Windows PC, automated.
Run **one file**, approve one UAC prompt, go get a coffee, and come back to a machine
with all my apps, a pretty terminal, and a checklist of the few things that can't be automated.

![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)
![Chocolatey](https://img.shields.io/badge/installs%20via-Chocolatey-80B5E3)
![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D6?logo=windows&logoColor=white)

---

## Table of contents

1. [Quick start](#-quick-start)
2. [What gets installed](#-what-gets-installed)
3. [The terminal setup](#-the-terminal-setup)
4. [How the setup works](#%EF%B8%8F-how-the-setup-works)
5. [Manual steps checklist](#-manual-steps-checklist)
6. [Customizing](#-customizing)
7. [Keeping the repo up to date](#-keeping-the-repo-up-to-date)
8. [Troubleshooting](#-troubleshooting)
9. [Repository layout](#-repository-layout)

---

## 🚀 Quick start

### Option A — straight from GitHub (fresh machine, no Git yet)

Open **PowerShell** (Win + X → *Terminal*) and paste:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/YOUR-GITHUB-USER/dotfiles/main/bootstrap.ps1 | iex
```

This downloads the repo to `%USERPROFILE%\dotfiles` and starts the setup.

> **Before the first use:** replace `YOUR-GITHUB-USER` in the command above **and** in `bootstrap.ps1`.
> If the repo is private, use option B instead.

### Option B — from a USB stick or downloaded ZIP

1. Copy / unzip the repo anywhere, e.g. `C:\Users\<you>\dotfiles`.
2. **Double-click `setup.cmd`.**

### What to expect

- A UAC prompt — the setup elevates itself.
- Roughly 30–60 minutes, depending on your connection.
- **One reboot** (for WSL). The setup schedules itself to continue automatically after you log back in; you'll just get one more UAC prompt.
- A summary table at the end, plus a to-do list of manual steps saved to your desktop as `setup-todo.txt`.

You can run `setup.cmd` again at any time. Everything that's already installed or already up to date is skipped, so it's also the way to **retry** anything that failed.

---

## 📦 What gets installed

Chocolatey goes in first; everything else is installed through it.

| App | Chocolatey package | Notes |
| --- | --- | --- |
| Chocolatey | — | Official install script |
| PowerShell 7 | `powershell-core` | The shell everything below is configured for |
| Windows Terminal | `microsoft-windows-terminal` | Skipped if the Windows 11 Store version already exists |
| Oh My Posh | `oh-my-posh` | Prompt theme engine |
| fzf | `fzf` | Fuzzy finder (replaces `scoop install fzf` from my old guide) |
| Git | `git` | |
| VS Code | `vscode` | No desktop icon |
| Sublime Text | `sublimetext4` | |
| Node.js + npm | `nodejs-lts` | LTS release |
| .NET | `dotnet-sdk` | Latest SDK |
| Python | `python` | Latest Python 3 |
| Docker Desktop | `docker-desktop` | Uses the WSL 2 backend |
| WSL 2 + Ubuntu 22.04 | `wsl --install` | Native installer, not Chocolatey |
| Firefox | `firefox` | |
| Spotify | `spotify` | See [troubleshooting](#spotify-fails-to-install) |
| Microsoft Teams | `microsoft-teams-new-bootstrapper` | The new Teams client |
| Slack | `slack` | |
| Discord | `discord` | |
| Obsidian | `obsidian` | |
| Steam | `steam` | |
| PowerToys | `powertoys` | |
| VLC | `vlc` | |

On top of that:

- **Font:** CaskaydiaCove Nerd Font (`oh-my-posh font install CascadiaCode`)
- **PowerShell modules:** PSReadLine (latest), Terminal-Icons, posh-git, z, PSFzf
- **Dotfiles:** PowerShell profile, Windows Terminal `settings.json`, the `microverse-power` Oh My Posh theme, global `.gitconfig`

---

## 🎨 The terminal setup

This is what my old "pretty PowerShell" guide did by hand — now fully automated.

| Piece | What it does | Where it comes from |
| --- | --- | --- |
| PowerShell 7 | Modern, cross-platform PowerShell | Chocolatey |
| Windows Terminal | Tabs, panes, themes | Store / Chocolatey |
| CaskaydiaCove NF | Nerd Font with the icons the prompt uses | `oh-my-posh font install` |
| Oh My Posh + `microverse-power` | Two-line powerline prompt: time, path, git status, exit code | `config/oh-my-posh/` → `C:\Prompt\` |
| Terminal-Icons | File/folder icons in `ls` output | PSGallery |
| posh-git | Git tab completion and status | PSGallery |
| z | `z proj` jumps to the most-used folder matching "proj" | PSGallery |
| PSReadLine | History-based predictions in a list view, menu completion on Tab | PSGallery |
| fzf + PSFzf | `Ctrl+T` fuzzy file search, `Ctrl+R` fuzzy history search | Chocolatey + PSGallery |

### Windows Terminal

`config/terminal/settings.json` sets PowerShell 7 as the default profile with the
**Andromeda** color scheme, a bar cursor and the Nerd Font at size 12.

| Shortcut | Action |
| --- | --- |
| `Ctrl+C` / `Ctrl+V` | Copy (when text is selected) / paste |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+D` | Split pane (duplicate current) |
| `Ctrl+Shift+W` | Close pane |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+F` | Find |

### PowerShell profile

`config/powershell/Microsoft.PowerShell_profile.ps1` is copied to
`Documents\PowerShell\Microsoft.PowerShell_profile.ps1` (the `$PROFILE` for PowerShell 7).

| Alias | Does |
| --- | --- |
| `google` | Opens google.com in the default browser |
| `subl [path]` | Opens Sublime Text (optionally with a file/folder) |
| `rider [path]` | Opens JetBrains Rider |
| `ws [path]` | Opens JetBrains WebStorm |

Compared to my original profile, this version:

- uses `$env:LOCALAPPDATA` / `$env:ProgramFiles` instead of hard-coded `C:\Users\palbo\...`, so it works with any username;
- shows a friendly warning instead of an error wall if a module or oh-my-posh is missing;
- passes relative paths like `subl .` as full paths, so they open the right folder;
- wires up PSFzf (`Ctrl+T`, `Ctrl+R`), which the old guide installed but never enabled. Delete that block if you prefer the default `Ctrl+R`.

### Git config

`config/git/.gitconfig` is copied to `%USERPROFILE%\.gitconfig`. Highlights:

| Setting | Effect |
| --- | --- |
| `init.defaultBranch = main` | New repos start on `main` |
| `pull.ff = only` | `git pull` never creates surprise merge commits |
| `push.autoSetupRemote = true` | First `git push` on a new branch just works, no `--set-upstream` |
| `core.autocrlf = false` | Git never rewrites line endings (the repo's `.gitattributes` handles that) |
| `core.editor` | Git for Windows' bundled vim |
| `diff.tool = vimdiff` | `git difftool` opens vimdiff without prompting |
| Git LFS filter | Large-file support (Git LFS ships with Git for Windows) |

| Alias | Does |
| --- | --- |
| `git hist` | Compact graph log with date and author |
| `git lg1` | Colorful graph of all branches |
| `git cleanup` | Deletes local branches already merged (keeps `master`/`develop` and the current one) |

**Your name and email are deliberately not in this repo.** The `.gitconfig` includes
`~/.gitconfig.local`, which the setup creates as an empty template. Set your identity there:

```powershell
git config --file ~/.gitconfig.local user.name  "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

That keeps personal/work details out of a public repo, and re-running the setup can never
overwrite them. (If you use `git config --global ...` instead, it writes to `.gitconfig`,
and the next setup run will replace that file — with a backup, but still.)

---

## ⚙️ How the setup works

`setup.cmd` → `setup.ps1` (self-elevating, always runs in Windows PowerShell 5.1 because
that's the only shell guaranteed to exist on a fresh install) → the numbered scripts in `scripts/`:

| # | Step | What happens |
| --- | --- | --- |
| 1 | `Chocolatey` | Installs Chocolatey and turns off confirmation prompts |
| 2 | `Apps` | Installs every package in `packages.psd1`, skipping ones already installed |
| 3 | `Fonts` | Installs CaskaydiaCove Nerd Font if it isn't there |
| 4 | `PowerShellModules` | Starts **pwsh** to install the modules (PowerShell 7 has its own module folder) |
| 5 | `Config` | Copies the theme, profile, terminal settings and `.gitconfig` into place. Existing files are backed up as `<file>.bak-<timestamp>` |
| 6 | `Npm` | Global npm packages from `NpmGlobal` (empty by default) |
| 7 | `WSL` | 1st run: installs the WSL platform and asks for a reboot. 2nd run (automatic): installs Ubuntu 22.04 |

Good to know:

- **Idempotent.** Re-running is always safe.
- **One failure doesn't stop the rest.** Every step and every package is handled separately and shows up in the summary.
- **Logs** of every run go to `logs/` (git-ignored). Chocolatey's own log is at `C:\ProgramData\chocolatey\logs\chocolatey.log`.
- **Skip steps** when you don't need them:

  ```powershell
  .\setup.cmd -Skip WSL,Npm
  .\setup.cmd -NoReboot        # never restart / never schedule the resume
  ```

---

## ✅ Manual steps checklist

Some things simply can't (or shouldn't) be automated — mostly signing in. The setup
prints the relevant ones at the end and saves them to `setup-todo.txt` on your desktop,
but here's the full list:

**Before you start**

- [ ] Virtualization is enabled in BIOS/UEFI (needed for WSL and Docker — usually on by default)

**After the setup**

- [ ] **WSL:** open *Ubuntu 22.04* from the Start menu once to create your Linux user, then `sudo apt update && sudo apt upgrade -y`
- [ ] **Docker Desktop:** start it, accept the terms, sign in, enable WSL integration for Ubuntu (*Settings → Resources → WSL integration*)
- [ ] **Git:** set your name/email in `~/.gitconfig.local` (see [Git config](#git-config)), then create SSH keys (`ssh-keygen -t ed25519`) and add them to GitHub
- [ ] **VS Code:** sign in to Settings Sync
- [ ] **Sublime Text:** enter license key
- [ ] **Firefox:** sign in to Firefox Sync
- [ ] **Spotify, Teams, Slack, Discord, Steam:** sign in
- [ ] **Obsidian:** open your vault / set up Obsidian Sync (settings and plugins live in the vault's `.obsidian` folder)
- [ ] **PowerToys:** restore settings via *Settings → General → Backup & restore*
- [ ] **JetBrains (optional):** install JetBrains Toolbox, then Rider and WebStorm (the `rider`/`ws` aliases expect Toolbox's default install location)
- [ ] **Clone this repo properly** now that Git exists, so you can push changes:
      `git clone git@github.com:YOUR-GITHUB-USER/dotfiles.git`

---

## 🛠 Customizing

Everything the setup installs is listed in **`packages.psd1`** — you should never need to edit the scripts to change the app list.

**Add an app**

```powershell
choco search obs          # find the package id
```

```powershell
# packages.psd1 -> Chocolatey
@{ Id = 'obs-studio'; Name = 'OBS Studio'; Manual = 'Import scene collection.' }
```

`Manual` is optional; when set, the text is added to the post-install checklist.
`Params` is optional too and is passed to Chocolatey as `--package-parameters`.

**Add a PowerShell module**

```powershell
# packages.psd1 -> PowerShellModules
@{ Name = 'PSScriptAnalyzer' }
```

**Other knobs** in the same file: `NpmGlobal`, `NerdFont`, `WslDistro` (see `wsl --list --online`).

---

## 🔄 Keeping the repo up to date

When you tweak your profile or terminal settings on a machine, pull them back into the repo:

```powershell
cd ~\dotfiles
.\scripts\export-config.ps1
git diff
git commit -am "Update terminal settings"
git push
```

This copies your live `$PROFILE`, Windows Terminal `settings.json`, the Oh My Posh theme and
`.gitconfig` back into `config/`.

---

## 🧯 Troubleshooting

#### "running scripts is disabled on this system"
Use `setup.cmd` (it passes `-ExecutionPolicy Bypass`), or run
`Set-ExecutionPolicy Bypass -Scope Process -Force` in the window first.

#### A package failed
Run `setup.cmd` again — it only retries what's missing. Still failing? Try
`choco install <id>` by hand and read `C:\ProgramData\chocolatey\logs\chocolatey.log`.
Community packages occasionally break when a vendor changes their download URL; installing
from the vendor's website is a fine fallback.

#### Spotify fails to install
Spotify's installer refuses to run as administrator. Open a **normal (non-admin)** terminal and run:

```powershell
winget install Spotify.Spotify
```

#### The prompt shows boxes / question marks instead of icons
The font isn't applied. Check that **CaskaydiaCove NF** shows up in *Settings → Personalization → Fonts*,
then restart Windows Terminal. VS Code's integrated terminal needs
`"terminal.integrated.fontFamily": "CaskaydiaCove NF"` too.

#### Terminal settings didn't change
Windows Terminal reads `settings.json` from
`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\` (Store version) or
`%LOCALAPPDATA%\Microsoft\Windows Terminal\` (unpackaged). The setup writes to whichever exist.
If a Preview build is your default, open *Settings → Open JSON file* and paste `config/terminal/settings.json`.

#### My Documents folder is in OneDrive
That's handled — the profile location comes from `[Environment]::GetFolderPath('MyDocuments')`.

#### I log in with a standard user and elevate with a separate admin account
The elevated process would then configure the *admin* account's profile. Either make your
daily account a local administrator for the setup, or run step 4 and 5 manually as yourself:
`pwsh -File scripts\install-modules.pwsh.ps1` and copy the files from `config/`.

#### WSL install fails
Enable virtualization in BIOS/UEFI, then run `wsl --install` in an admin terminal, reboot, and run `setup.cmd` again.

---

## 📁 Repository layout

```
dotfiles/
├── setup.cmd                    # ← double-click this
├── bootstrap.ps1                # one-liner entry point (downloads repo, runs setup.cmd)
├── setup.ps1                    # orchestrator: elevation, steps, summary, reboot/resume
├── packages.psd1                # ← the app/module/npm list. Edit this.
├── scripts/
│   ├── common.ps1               # logging + helpers
│   ├── 01-chocolatey.ps1
│   ├── 02-apps.ps1
│   ├── 03-fonts.ps1
│   ├── 04-powershell-modules.ps1
│   ├── install-modules.pwsh.ps1 # runs inside PowerShell 7
│   ├── 05-config.ps1
│   ├── 06-npm.ps1
│   ├── 07-wsl.ps1
│   └── export-config.ps1        # copy live config back into the repo
└── config/
    ├── powershell/Microsoft.PowerShell_profile.ps1
    ├── terminal/settings.json
    ├── git/.gitconfig                     # → %USERPROFILE%\.gitconfig
    └── oh-my-posh/microverse-power.json   # → C:\Prompt\
```

---

<sub>Built on the shoulders of [Chocolatey](https://chocolatey.org), [Oh My Posh](https://ohmyposh.dev),
[Nerd Fonts](https://www.nerdfonts.com), [Terminal-Icons](https://github.com/devblackops/Terminal-Icons),
[posh-git](https://github.com/dahlbyk/posh-git), [PSFzf](https://github.com/kelleyma49/PSFzf) and
[z](https://github.com/badmotorfinger/z).</sub>
