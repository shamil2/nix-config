{ config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "kubectl"
        "systemd"
        "extract"
        "colored-man-pages"
        "command-not-found"
        "direnv"
        "fzf"
        "gh"
        "history"
      ];
    };

    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/nix-config";
      NH_FLAKE = "${config.home.homeDirectory}/nix-config";
      NH_OS_FLAKE = "${config.home.homeDirectory}/nix-config";
    };

    shellAliases = {
      cat = "bat --paging=never";
      ".." = "cd ..";
      "..." = "cd ../..";
      rebuild = "nh os switch ~/nix-config";
      nix-test = "nh os test ~/nix-config";
      nix-clean = "nh clean all";
    };

    initContent = ''
      export FLAKE="${config.home.homeDirectory}/nix-config"
      export NH_FLAKE="${config.home.homeDirectory}/nix-config"
      export NH_OS_FLAKE="${config.home.homeDirectory}/nix-config"
    '';
  };
}
