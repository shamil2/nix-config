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
      rebuild = "nh os switch";
      nix-test = "nh os test";
      nix-clean = "nh clean all";
    };
  };
}
