{ pkgs, ... }:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    pciutils
    usbutils
    coreutils
    killall
    tree
    fastfetch
  ];
}
