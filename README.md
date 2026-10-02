# ❄️ NixOS & Home Manager Configuration

Modular NixOS Flake configuration inspired by [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## 📁 Repository Structure

```
├── flake.nix                  # Flake entrypoint and inputs definition
├── flake.lock                 # Locked input dependencies
├── Justfile                   # Handy operational recipes
├── vars/
│   └── default.nix            # System & user variables (locale, timezone, keyboard, user)
├── lib/
│   ├── default.nix            # Library helpers (scanPaths, relativeToRoot)
│   └── nixosSystem.nix        # System builder wrapping nixpkgs & home-manager
├── modules/
│   ├── base/                  # Cross-platform common modules
│   │   ├── nix.nix            # Flakes & experimental-features
│   │   └── security.nix       # Sudo & Polkit
│   └── nixos/                 # NixOS system-level configuration
│       ├── base/              # Base system modules (auto-imported via scanPaths)
│       │   ├── core.nix       # systemd-boot bootloader
│       │   ├── i18n.nix       # Locale (fr_FR.UTF-8), keyboard (fr) & timezone
│       │   ├── networking.nix # NetworkManager
│       │   ├── nix.nix        # Nix daemon & gc settings
│       │   ├── packages.nix   # Essential base packages
│       │   └── user-group.nix # User account & groups
│       ├── desktop.nix        # Desktop profile toggles
│       └── desktop/           # Desktop environment modules
│           ├── audio.nix      # PipeWire & rtkit
│           ├── display-manager.nix # GDM display manager
│           ├── fonts.nix      # Nerd Fonts (JetBrainsMono, FiraCode)
│           ├── graphics.nix   # Mesa & OpenGL/Vulkan
│           ├── niri.nix       # Niri Wayland compositor & portals
│           └── peripherals.nix# CUPS printing & Bluetooth
├── hosts/
│   └── nixos/                 # Host-specific configuration
│       ├── default.nix        # Host entrypoint
│       └── hardware-configuration.nix # Hardware scan
└── home/                      # User environment (Home Manager)
    ├── default.nix            # User profile entrypoint
    ├── base/
    │   ├── home.nix           # State version & home-manager setup
    │   └── core/              # CLI / shell / editor stack
    │       ├── bash.nix       # Bash config & aliases
    │       ├── git.nix        # Git configuration
    │       ├── starship.nix   # Catppuccin-styled prompt
    │       ├── shells/        # Nushell
    │       ├── editors/       # Helix & Neovim
    │       └── zellij/        # Terminal multiplexer
    └── linux/
        ├── base/              # Linux desktop CLI/GUI base
        │   ├── apps.nix       # VS Code, Google Chrome, Obsidian, Firefox
        │   ├── btop.nix       # Resource monitor
        │   ├── fastfetch.nix  # System fetch
        │   ├── gtk.nix        # Dark theme & cursor
        │   └── yazi.nix       # Terminal file manager
        └── gui/               # Window manager configs
            └── niri/          # Niri Wayland desktop rice
                ├── default.nix# Alacritty, Fuzzel, Waybar, Mako
                └── conf/      # KDL configuration files
```

## 🚀 Usage & Deployment

### Quick Commands (via `just`)

```bash
# Switch to the new configuration
just switch

# Or test without setting as default boot entry
just test

# Build the system without root permissions
just build

# Update dependencies
just update
```

### Standard `nixos-rebuild`

```bash
# Deploy with nixos-rebuild (--no-reexec prevents systemd-run mismatch during upgrade)
sudo nixos-rebuild switch --flake ~/nix-config#nixos --no-reexec

# Test without permanent switch
sudo nixos-rebuild test --flake ~/nix-config#nixos --no-reexec
```

## 🎨 Desktop Environment

- **Wayland Window Manager**: [Niri](https://github.com/YaLTeR/niri) (Scrollable tiling window manager)
- **Status Bar**: Waybar (Catppuccin theme)
- **Launcher**: Fuzzel
- **Terminal**: Alacritty & Nushell
- **Editor**: Helix (default) & Neovim
- **Prompt**: Starship
- **Display Manager**: GDM (allows selecting either Niri or GNOME at login)
