{ myvars, ... }:
{
  home = {
    username = myvars.username;
    homeDirectory = "/home/${myvars.username}";
    stateVersion = "25.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
