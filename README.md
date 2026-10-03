# ❄️ NixOS & Home Manager Configuration

A modular, reproducible, and batteries-included NixOS Flake configuration featuring a modern Wayland rice (Niri), SRE/DevOps tooling, and user environment managed via Home Manager. Inspired by [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

---

## ✨ Highlights & Features

- **Tiling Wayland Desktop**: [Niri](https://github.com/YaLTeR/niri) scrollable tiling Wayland compositor paired with GNOME/GDM session.
- **Polished Theming**: Consistent **Catppuccin Mocha** dark aesthetic across Waybar, Alacritty, Starship, Helix, Lazygit, FZF, Btop, and GTK.
- **Interactive Status Bar**: Customized **Waybar** featuring live network bandwidth (upload/download), interactive clipboard history manager, battery health, volume/brightness controls, and system monitors.
- **Biometric Security**: Password and fingerprint authentication via `fprintd` for `sudo`, `polkit`, and `hyprlock`.
- **Power Management**: Configured hibernation on laptop lid switch and suspend when plugged in.
- **SRE & DevOps Stack**:
  - Podman container engine with Docker compatibility & Podman Compose.
  - Kubernetes CLI tools: `kubectl`, `k9s`, `helm`.
  - Cloud tooling: `google-cloud-sdk`.
  - Developer environments: `devenv`, `direnv`.
  - CLI data tools: `jq`, `yq-go`, `ripgrep`, `fd`.
- **Modern CLI & Shells**:
  - Shells: Nushell & Bash with smart completions and history.
  - Prompt: Starship with Git branch/status, language runtimes, container context, and command duration.
  - Editors: Helix (primary modal editor) and Neovim.
  - Terminal Multiplexer: Zellij.
  - Utilities: Lazygit (with `delta`), Atuin shell history, FZF, Zoxide, Yazi file manager, Fastfetch, and Btop.
- **Modern Flake Workflow**: Managed with `nh` (Yet another Nix Helper), `nvd` for diff tracking, `nom` (nix-output-monitor), and `just` task runner.

---

## 📁 Repository Structure

```
├── .gitignore                 # Standard Nix, IDE & temporary file ignores
├── flake.nix                  # Flake entrypoint and inputs definition
├── flake.lock                 # Pinned flake dependency lockfile
├── Justfile                   # Operational recipes (switch, test, boot, clean, update)
├── vars/
│   └── default.nix            # System & user variables (user, email, timezone, locales, keyboard)
├── lib/
│   ├── default.nix            # Library helpers (scanPaths, relativeToRoot)
│   └── nixosSystem.nix        # System builder wrapping nixpkgs & home-manager
├── modules/
│   ├── base/                  # Cross-platform core modules
│   │   ├── nix.nix            # Flakes & experimental features, binary caches
│   │   └── security.nix       # Sudo, Polkit & fingerprint authentication
│   └── nixos/                 # NixOS system-level configuration
│       ├── base/              # Base system modules (auto-imported via scanPaths)
│       │   ├── core.nix       # systemd-boot bootloader, lid close & power handling
│       │   ├── containers.nix # Podman runtime & Docker emulation
│       │   ├── dev-sre.nix    # SRE tools (k8s, helm, gcloud, devenv, jq, yq, rg, fd)
│       │   ├── i18n.nix       # Locale (fr_FR.UTF-8), keyboard (fr) & timezone
│       │   ├── networking.nix # NetworkManager & DHCP
│       │   ├── nix.nix        # Nix daemon, auto-optimise & garbage collection
│       │   ├── packages.nix   # System packages, nh helper & nix-output-monitor
│       │   └── user-group.nix # User accounts & permissions
│       ├── desktop.nix        # Desktop environment toggles
│       └── desktop/           # Desktop stack modules
│           ├── audio.nix      # PipeWire & rtkit low-latency audio
│           ├── display-manager.nix # GDM display manager (Niri & GNOME)
│           ├── fonts.nix      # Nerd Fonts (JetBrainsMono, FiraCode) & Noto fonts
│           ├── graphics.nix   # Mesa & OpenGL/Vulkan acceleration
│           ├── niri.nix       # Niri compositor, portals & desktop utilities
│           └── peripherals.nix# CUPS printing, Bluetooth & keyboard layout
├── hosts/
│   └── nixos/                 # Machine-specific configuration
│       ├── default.nix        # Host entrypoint, hostname & profile options
│       └── hardware-configuration.nix # Hardware scan (disks, swap, CPU modules)
└── home/                      # User environment (Home Manager)
    ├── default.nix            # User profile entrypoint
    ├── base/
    │   ├── home.nix           # Home Manager state version & home directory setup
    │   └── core/              # Shell, editor & CLI stack
    │       ├── bash.nix       # Bash config, aliases & flake environment variables
    │       ├── git.nix        # Git configuration
    │       ├── starship.nix   # Starship prompt configuration (Catppuccin Mocha)
    │       ├── tools.nix      # Lazygit, FZF, Atuin history & Zoxide
    │       ├── shells/        # Nushell configuration
    │       ├── editors/       # Helix & Neovim editors
    │       └── zellij/        # Zellij terminal multiplexer
    └── linux/
        ├── base/              # Linux desktop CLI/GUI applications
        │   ├── apps.nix       # VS Code, Google Chrome, Obsidian, Firefox
        │   ├── btop.nix       # Btop resource monitor with Catppuccin theme
        │   ├── fastfetch.nix  # Fastfetch system info layout
        │   ├── gtk.nix        # Dark theme, Papirus icons & Bibata cursor
        │   └── yazi.nix       # Yazi terminal file manager
        └── gui/               # GUI & window manager configuration
            └── niri/          # Niri rice setup & autostart
                ├── default.nix# Alacritty, Fuzzel, Waybar, Mako, wallpaper rotator
                └── conf/      # Niri KDL files & Hyprlock config
```

---

## 🛠️ Getting Started / Deployment

### 1. Clone the repository

```bash
git clone https://github.com/<username>/nix-config.git ~/nix-config
cd ~/nix-config
```

### 2. Customize variables

Edit `vars/default.nix` to match your identity, preferred timezone, and keyboard layout:

```nix
{ lib }:
{
  username = "yourusername";
  userfullname = "Your Name";
  useremail = "your.email@example.com";

  timeZone = "Europe/Paris";
  defaultLocale = "en_US.UTF-8";
  keyboardLayout = "us"; # or "fr"
}
```

### 3. Generate hardware configuration

If deploying onto a new machine, generate your system's hardware configuration:

```bash
nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

> **Note**: Update the swap partition UUID in `modules/nixos/base/core.nix` (`boot.resumeDevice`) if you enable hibernation.

### 4. Build and apply

Manage your system using `just` (recommended) or `nh`:

```bash
# Test configuration without setting as default boot entry
just test

# Switch to the new configuration
just switch

# Build the system without switching (dry-run)
just build
```

---

## ⚡ Task Runner (`just`)

This repository includes a `Justfile` to streamline common maintenance operations:

| Command | Action |
| :--- | :--- |
| `just switch` | Build and activate system configuration via `nh` |
| `just test` | Test configuration in the current session without updating bootloader |
| `just boot` | Build and add to bootloader as next boot entry |
| `just build` | Dry-run build of toplevel derivation |
| `just update` | Update flake inputs (`flake.lock`) |
| `just check` | Check flake evaluation and structure |
| `just clean` | Store cleanup and garbage collection (keeps last 5 generations) |

---

## ⌨️ Niri Desktop Shortcuts

| Keybinding | Action |
| :--- | :--- |
| `Mod + Return` / `Mod + T` | Open terminal (`alacritty`) |
| `Mod + Space` / `Mod + D` | Application launcher (`fuzzel`) |
| `Mod + V` | Interactive clipboard history (`cliphist` + `fuzzel`) |
| `Mod + Q` | Close active window |
| `Mod + F` | Maximize active column |
| `Mod + Shift + F` | Fullscreen window toggle |
| `Mod + R` | Cycle preset column widths (33% / 50% / 66%) |
| `Mod + H/J/K/L` or `Arrows` | Move focus (Left / Down / Up / Right) |
| `Mod + Shift + H/J/K/L` or `Arrows` | Move window/column position |
| `Mod + 1-9` (or `&`, `é`, `"`, `'`, `(`, `-`, `è`, `_`, `ç`) | Switch workspace |
| `Mod + Shift + 1-9` | Move column to workspace |
| `Mod + Escape` / `Mod + Alt + L` | Lock screen (`hyprlock`) |
| `Print` / `Ctrl + Print` / `Alt + Print` | Screenshot (Interactive / Full screen / Active window) |
| `Mod + Shift + E` | Quit Niri session |

---

## 🔒 Security & Privacy Notice

- **No Secrets Stored in Repo**: This repository contains no plain-text passwords, tokens, API keys, or private SSH keys.
- **Credentials**: Authentication secrets and sensitive credentials should be managed via external tools such as `sops-nix`, `agenix`, or manual interaction.
