{ config, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/nix-config";
      NH_FLAKE = "${config.home.homeDirectory}/nix-config";
      NH_OS_FLAKE = "${config.home.homeDirectory}/nix-config";
    };
    bashrcExtra = ''
      export FLAKE="${config.home.homeDirectory}/nix-config"
      export NH_FLAKE="${config.home.homeDirectory}/nix-config"
      export NH_OS_FLAKE="${config.home.homeDirectory}/nix-config"
    '';
    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      rebuild = "nh os switch ~/nix-config";
      nix-test = "nh os test ~/nix-config";
      nix-clean = "nh clean all";
    };
  };
}
