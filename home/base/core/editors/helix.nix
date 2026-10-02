{ ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        cursorline = true;
        mouse = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        statusline = {
          left = [ "mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator" ];
          center = [ ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
          separator = "│";
        };
      };
    };
  };
}
