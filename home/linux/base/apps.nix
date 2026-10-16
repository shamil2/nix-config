{ pkgs, ... }:
{
  home.packages = with pkgs; [
    electron
    google-chrome
    gh
    obsidian
    opencode
    vscode
  ];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
}
