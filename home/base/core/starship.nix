{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    settings = {
      format = "$os$username$sudo$directory$git_branch$git_status$fill$package$nodejs$rust$golang$python$docker_context$nix_shell$cmd_duration$line_break$character";

      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      os = {
        disabled = false;
        symbols = {
          NixOS = " ";
        };
        style = "bold sapphire";
        format = "[$symbol]($style)";
      };

      username = {
        show_always = false;
        style_user = "bold lavender";
        style_root = "bold red";
        format = "[$user]($style) in ";
      };

      sudo = {
        disabled = false;
        symbol = "󰌋 ";
        style = "bold yellow";
        format = "[$symbol]($style)";
      };

      directory = {
        style = "bold mauve";
        truncation_length = 4;
        truncate_to_repo = true;
        read_only = " 󰌾";
        read_only_style = "red";
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = " ";
        style = "bold pink";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold maroon";
        conflicted = "🏳 ";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕⇡$ahead_count⇣$behind_count ";
        untracked = "$count ";
        stashed = "📦 ";
        modified = "$count ";
        staged = "●$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
      };

      fill = {
        symbol = " ";
      };

      package = {
        symbol = "󰏗 ";
        style = "peach";
        format = "[$symbol$version]($style) ";
      };

      nodejs = {
        symbol = "󰏈 ";
        style = "green";
        format = "[$symbol($version )]($style)";
      };

      rust = {
        symbol = "󱘗 ";
        style = "peach";
        format = "[$symbol($version )]($style)";
      };

      golang = {
        symbol = "󰟓 ";
        style = "sky";
        format = "[$symbol($version )]($style)";
      };

      python = {
        symbol = "󰌠 ";
        style = "yellow";
        format = "[$symbol$pyenv_prefix($version )(\\($virtualenv\\) )]($style)";
      };

      docker_context = {
        symbol = "󰡨 ";
        style = "blue";
        format = "[$symbol$context]($style) ";
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold sky";
        format = "via [$symbol$name]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "took [$duration]($style)";
      };

      character = {
        success_symbol = "[❯](bold mauve)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
    };
  };
}
