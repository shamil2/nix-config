{ config, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nix-config#nixos";
      nix-test = "sudo nixos-rebuild test --flake ${config.home.homeDirectory}/nix-config#nixos";
    };
  };
}
