{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    settings = {
      format = "[](surface0)$os$username$sudo[](bg:peach fg:surface0)$directory[](fg:peach bg:green)$git_branch$git_status[](fg:green bg:teal)$nodejs$rust$golang$python$docker_context$nix_shell[](fg:teal bg:lavender)$cmd_duration$time[ ](fg:lavender)$line_break$character";

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
        style = "bg:surface0 fg:sapphire";
        symbols = {
          NixOS = " ";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:surface0 fg:text";
        style_root = "bg:surface0 fg:red";
        format = "[ $user ]($style)";
      };

      sudo = {
        disabled = false;
        symbol = "󰌋 ";
        style = "bg:surface0 fg:yellow";
        format = "[$symbol]($style)";
      };

      directory = {
        style = "bg:peach fg:crust bold";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        read_only = " 󰌾 ";
        read_only_style = "bg:peach fg:red";
      };

      git_branch = {
        symbol = "";
        style = "bg:green fg:crust bold";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:green fg:crust bold";
        format = "([$all_status$ahead_behind ]($style))";
        conflicted = "🏳 ";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕⇡$ahead_count⇣$behind_count ";
        untracked = "?$count ";
        stashed = "📦 ";
        modified = "!$count ";
        staged = "+$count ";
        renamed = "»$count ";
        deleted = "✘$count ";
      };

      nodejs = {
        symbol = "";
        style = "bg:teal fg:crust";
        format = "[ $symbol( $version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:teal fg:crust";
        format = "[ $symbol( $version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:teal fg:crust";
        format = "[ $symbol( $version) ]($style)";
      };

      python = {
        symbol = "";
        style = "bg:teal fg:crust";
        format = "[ $symbol( $version) ]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:teal fg:crust";
        format = "[ $symbol( $context) ]($style)";
      };

      nix_shell = {
        symbol = "";
        style = "bg:teal fg:crust bold";
        format = "[ $symbol( $name) ]($style)";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bg:lavender fg:crust bold";
        format = "[  $duration ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender fg:crust";
        format = "[  $time ]($style)";
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:mauve)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
      };
    };
  };
}
