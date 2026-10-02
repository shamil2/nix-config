{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop.wayland;
in
{
  config = lib.mkIf cfg.enable {
    # Enable Niri scrollable tiling Wayland compositor
    programs.niri.enable = true;

    # Enable Hyprlock screen locker
    programs.hyprlock.enable = true;

    # Wayland desktop environment utilities & tools
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      alacritty
      fuzzel
      mako
      swaybg
      waybar
      wl-clipboard
      cliphist
      grim
      slurp
      wlsunset
      brightnessctl
      playerctl
      pavucontrol
      networkmanagerapplet
    ];

    # XDG Desktop Portal for Wayland
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
