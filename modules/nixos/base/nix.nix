{ lib, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Auto-optimise store
  nix.settings.auto-optimise-store = true;
}
