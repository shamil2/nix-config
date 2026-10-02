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
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    builders-use-substitutes = true;
  };
}
