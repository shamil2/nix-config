{ lib, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Garbage collection handled by programs.nh.clean
  nix.gc.automatic = false;

  # Auto-optimise store
  nix.settings.auto-optimise-store = true;
}
