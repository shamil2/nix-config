{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.desktop;
in
{
  imports = [
    ./base
    ../base
    ./desktop
  ];

  options.modules.desktop = {
    enable = lib.mkEnableOption "Desktop environment";
    wayland = {
      enable = lib.mkEnableOption "Wayland window manager (Niri)";
    };
    gnome = {
      enable = lib.mkEnableOption "GNOME Desktop (can run alongside Niri)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Desktop defaults enabled when modules.desktop.enable = true
    modules.desktop.wayland.enable = lib.mkDefault true;
    modules.desktop.gnome.enable = lib.mkDefault true;
  };
}
