{ ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = false; # manual start
  };

  xdg.configFile."zellij/config.kdl".text = ''
    theme "catppuccin-mocha"
    default_layout "compact"
    pane_frames false
  '';
}
