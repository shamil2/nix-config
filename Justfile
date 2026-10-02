# Justfile for NixOS Flake Management
# Inspired by ryan4yin/nix-config

FLAKE := invocation_directory()

default:
    @just --list

# Switch system configuration (modern via nh)
switch:
    nh os switch {{ FLAKE }}

# Test system configuration without adding to bootloader
test:
    nh os test {{ FLAKE }}

# Build configuration and set it as next boot entry without switching now
boot:
    nh os boot {{ FLAKE }}

# Build system toplevel derivation only (dry-run / build)
build:
    nh os build {{ FLAKE }}

# Update all flake inputs
update:
    nix --extra-experimental-features "nix-command flakes" flake update

# Check flake structure and evaluation
check:
    nix --extra-experimental-features "nix-command flakes" flake check

# Garbage collection and store cleanup (modern via nh)
clean:
    nh clean all --keep 5
