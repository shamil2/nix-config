{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/desktop.nix
  ];

  # Hostname
  networking.hostName = "nixos";

  # Enable desktop environment stack (Niri Wayland rice + GNOME)
  modules.desktop.enable = true;

  # System state version
  system.stateVersion = "25.11";
}
