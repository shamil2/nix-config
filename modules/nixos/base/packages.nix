{ pkgs, myvars, ... }:
{
  # Modern Nix helper (nh)
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "/home/${myvars.username}/nix-config";
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    just
    pciutils
    usbutils
    coreutils
    killall
    tree
    fastfetch
    nvd
    nix-output-monitor
  ];
}
