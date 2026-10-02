{ ... }:
{
  programs.nushell = {
    enable = true;
    configFile.text = ''
      $env.config = {
        show_banner: false,
      }
    '';
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
    };
  };
}
