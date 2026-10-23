{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    # Unset NIRI_SOCKET for Yazi so Alacritty falls back to Chafa image rendering
    # instead of attempting ueberzugpp (which fails on Niri tiled windows).
    package = pkgs.symlinkJoin {
      name = "yazi-wrapped";
      paths = [ pkgs.yazi ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/yazi --set NIRI_SOCKET ""
      '';
    };
    shellWrapperName = "y";
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    # ~/.config/yazi/yazi.toml
    settings = {
      mgr = {
        ratio = [ 1 3 4 ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        sort_translit = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 5;
        mouse_events = [ "click" "scroll" "drag" ];
      };

      preview = {
        wrap = "yes";
        tab_size = 2;
        max_width = 1920;
        max_height = 1080;
        image_filter = "lanczos3";
        image_quality = 90;
        image_delay = 10;
      };
    };

    # ~/.config/yazi/theme.toml (Catppuccin Mocha)
    theme = {
      mgr = {
        cwd = { fg = "#94e2d5"; bold = true; };

        find_keyword = { fg = "#f9e2af"; bold = true; italic = true; underline = true; };
        find_position = { fg = "#f5c2e7"; bg = "reset"; bold = true; italic = true; };

        symlink_target = { fg = "#94e2d5"; italic = true; };

        marker_copied = { fg = "#a6e3a1"; bg = "#a6e3a1"; };
        marker_cut = { fg = "#f38ba8"; bg = "#f38ba8"; };
        marker_marked = { fg = "#94e2d5"; bg = "#94e2d5"; };
        marker_selected = { fg = "#f9e2af"; bg = "#f9e2af"; };
        marker_symbol = "│";

        count_copied = { fg = "#1e1e2e"; bg = "#a6e3a1"; bold = true; };
        count_cut = { fg = "#1e1e2e"; bg = "#f38ba8"; bold = true; };
        count_selected = { fg = "#1e1e2e"; bg = "#f9e2af"; bold = true; };

        border_symbol = "│";
        border_style = { fg = "#585b70"; };
      };

      tabs = {
        active = { fg = "#1e1e2e"; bg = "#cba6f7"; bold = true; };
        inactive = { fg = "#cdd6f4"; bg = "#313244"; };
        sep_inner = { open = ""; close = ""; };
        sep_outer = { open = ""; close = ""; };
      };

      mode = {
        normal_main = { fg = "#1e1e2e"; bg = "#cba6f7"; bold = true; };
        normal_alt = { fg = "#cba6f7"; bg = "#313244"; };

        select_main = { fg = "#1e1e2e"; bg = "#a6e3a1"; bold = true; };
        select_alt = { fg = "#a6e3a1"; bg = "#313244"; };

        unset_main = { fg = "#1e1e2e"; bg = "#f38ba8"; bold = true; };
        unset_alt = { fg = "#f38ba8"; bg = "#313244"; };
      };

      indicator = {
        parent = { fg = "#1e1e2e"; bg = "#89b4fa"; bold = true; };
        current = { fg = "#1e1e2e"; bg = "#cba6f7"; bold = true; };
        preview = { fg = "#cba6f7"; underline = true; };
        padding = { open = ""; close = ""; };
      };

      status = {
        sep_left = { open = ""; close = ""; };
        sep_right = { open = ""; close = ""; };

        perm_sep = { fg = "#585b70"; };
        perm_type = { fg = "#a6e3a1"; };
        perm_read = { fg = "#f9e2af"; };
        perm_write = { fg = "#f38ba8"; };
        perm_exec = { fg = "#89dceb"; };

        progress_label = { fg = "#cdd6f4"; bold = true; };
        progress_normal = { fg = "#a6e3a1"; bg = "#45475a"; };
        progress_error = { fg = "#f38ba8"; bg = "#45475a"; };
      };

      which = {
        cols = 3;
        border = { fg = "#cba6f7"; };
        mask = { bg = "#181825"; };
        cand = { fg = "#94e2d5"; bold = true; };
        rest = { fg = "#6c7086"; };
        desc = { fg = "#f5c2e7"; };
        separator = "  ";
        separator_style = { fg = "#585b70"; };
      };

      confirm = {
        border = { fg = "#cba6f7"; };
        title = { fg = "#cba6f7"; bold = true; };
        body = { fg = "#cdd6f4"; };
        list = { fg = "#cdd6f4"; };
        btn_yes = { fg = "#1e1e2e"; bg = "#a6e3a1"; bold = true; };
        btn_no = { fg = "#cdd6f4"; bg = "#313244"; };
      };

      spot = {
        border = { fg = "#cba6f7"; };
        title = { fg = "#cba6f7"; bold = true; };
        tbl_col = { fg = "#89b4fa"; };
        tbl_cell = { fg = "#f9e2af"; reversed = true; };
      };

      notify = {
        title_info = { fg = "#a6e3a1"; bold = true; };
        title_warn = { fg = "#f9e2af"; bold = true; };
        title_error = { fg = "#f38ba8"; bold = true; };
        icon_info = "";
        icon_warn = "";
        icon_error = "";
      };

      pick = {
        border = { fg = "#cba6f7"; };
        active = { fg = "#f5c2e7"; bold = true; };
        inactive = { fg = "#cdd6f4"; };
      };

      input = {
        border = { fg = "#cba6f7"; };
        title = { fg = "#cba6f7"; bold = true; };
        value = { fg = "#cdd6f4"; };
        selected = { reversed = true; };
      };

      cmp = {
        border = { fg = "#cba6f7"; };
        active = { fg = "#1e1e2e"; bg = "#cba6f7"; bold = true; };
        inactive = { fg = "#cdd6f4"; };
        icon_file = "";
        icon_folder = "";
        icon_command = "";
      };

      tasks = {
        border = { fg = "#cba6f7"; };
        title = { fg = "#cba6f7"; bold = true; };
        hovered = { fg = "#f5c2e7"; bold = true; };
      };

      help = {
        border = { fg = "#cba6f7"; };
        chord = { fg = "#94e2d5"; bold = true; };
        action = { fg = "#cdd6f4"; };
        hovered = { fg = "#1e1e2e"; bg = "#cba6f7"; bold = true; };
      };

      filetype = {
        rules = [
          { mime = "image/*"; fg = "#f9e2af"; }
          { mime = "{audio,video}/*"; fg = "#f5c2e7"; }
          { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = "#f38ba8"; }
          { mime = "application/{pdf,doc,rtf}"; fg = "#94e2d5"; }
          { mime = "vfs/{absent,stale}"; fg = "#6c7086"; }
          { url = "*"; is = "orphan"; bg = "#f38ba8"; fg = "#1e1e2e"; }
          { url = "*"; is = "exec"; fg = "#a6e3a1"; }
          { url = "*"; is = "dummy"; bg = "#f38ba8"; fg = "#1e1e2e"; }
          { url = "*/"; is = "dummy"; bg = "#f38ba8"; fg = "#1e1e2e"; }
          { url = "*/"; fg = "#89b4fa"; bold = true; }
        ];
      };
    };
  };
}
