{ config, ... }:
{
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config = {
        show_banner: false,
      }
      $env.FLAKE = "${config.home.homeDirectory}/nix-config"
      $env.NH_FLAKE = "${config.home.homeDirectory}/nix-config"
    '';
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
    };
  };
}
