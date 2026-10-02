{ ... }:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableBashIntegration = true;
    enableNushellIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
      };
    };
  };
}
