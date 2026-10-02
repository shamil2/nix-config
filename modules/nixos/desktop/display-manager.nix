{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgGnome = config.modules.desktop.gnome;
in
{
  # Display Manager & Desktop Session
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = cfgGnome.enable;
}
