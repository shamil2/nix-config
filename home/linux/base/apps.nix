{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    obsidian
    opencode
    vscode
  ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
}
