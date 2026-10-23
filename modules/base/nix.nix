{ ... }:
{
  nix.settings = {
    # Enable Flakes and the new nix command line tool
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Binary cache configuration
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    builders-use-substitutes = true;
    sandbox = true;
    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "@wheel" ];
  };
}
