{
  description = "sha1000's NixOS & Home Manager Configuration";

  inputs = {
    # Official NixOS package source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wallpapers repository (ryan4yin/wallpapers)
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };

    # Additional Anime Wallpapers (codingcodax/wallpapers)
    wallpapers-extra = {
      url = "github:codingcodax/wallpapers";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      wallpapers,
      wallpapers-extra,
      ...
    }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      mylib = import ./lib { inherit lib; };
      myvars = import ./vars { inherit lib; };

      genSpecialArgs = system: inputs // {
        inherit mylib myvars;
      };
    in
    {
      # NixOS Host Configurations
      nixosConfigurations = {
        nixos = mylib.nixosSystem {
          inherit inputs lib system genSpecialArgs myvars;
          nixos-modules = [
            ./hosts/nixos
          ];
          home-modules = [
            ./home
          ];
        };
      };
    };
}
