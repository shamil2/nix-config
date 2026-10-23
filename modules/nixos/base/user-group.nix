{ pkgs, myvars, ... }:
{
  # Enable Zsh system-wide
  programs.zsh.enable = true;

  # Define user account
  users.users."${myvars.username}" = {
    isNormalUser = true;
    description = myvars.userfullname;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
  };
}
