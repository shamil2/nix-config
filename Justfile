# Justfile for NixOS Flake Management
# Inspired by ryan4yin/nix-config

default:
    @just --list

# Switch system configuration to this flake
switch:
    sudo nixos-rebuild switch --flake .#nixos --no-reexec

# Test system configuration without adding to bootloader
test:
    sudo nixos-rebuild test --flake .#nixos --no-reexec

# Build configuration and set it as next boot entry without switching now
boot:
    sudo nixos-rebuild boot --flake .#nixos --no-reexec

# Build system toplevel derivation only (no root required)
build:
    nix --extra-experimental-features "nix-command flakes" build .#nixosConfigurations.nixos.config.system.build.toplevel

# Update all flake inputs
update:
    nix --extra-experimental-features "nix-command flakes" flake update

# Check flake structure and evaluation
check:
    nix --extra-experimental-features "nix-command flakes" flake check

# Garbage collection and store cleanup
clean:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d
    sudo nix-store --optimise
