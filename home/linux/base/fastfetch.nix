{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "small";
      };
      display = {
        separator = " ➜ ";
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "break"
        "colors"
      ];
    };
  };
}
