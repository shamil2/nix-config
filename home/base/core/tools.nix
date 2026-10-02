{ ... }:
{
  # Lazygit TUI with Catppuccin Mocha theme
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
      gui = {
        theme = {
          activeBorderColor = [ "#cba6f7" "bold" ];
          inactiveBorderColor = [ "#585b70" ];
          searchingActiveBorderColor = [ "#f9e2af" "bold" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitFgColor = [ "#89dceb" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          markedBaseCommitFgColor = [ "#89dceb" ];
          markedBaseCommitBgColor = [ "#a6e3a1" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
        };
      };
    };
  };

  # FZF fuzzy finder
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # Let Atuin handle Ctrl-R history search
    historyWidget.command = "";
    colors = {
      bg = "#1e1e2e";
      "bg+" = "#313244";
      fg = "#cdd6f4";
      "fg+" = "#cdd6f4";
      header = "#f38ba8";
      info = "#cba6f7";
      pointer = "#f5e0dc";
      marker = "#b4befe";
      prompt = "#cba6f7";
      spinner = "#f5e0dc";
    };
  };

  # Atuin shell history sync & search
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "global";
      style = "compact";
      inline_height = 20;
    };
  };

  # Zoxide (smarter cd command)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  # Direnv with nix-direnv (fast Nix shell loading)
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
