{
  pkgs,
  wallpapers,
  wallpapers-extra,
  ...
}:
let
  # Per-workspace dynamic wallpaper daemon for Niri
  wallpaper-rotator = pkgs.writeScriptBin "wallpaper-rotator" ''
    #!${pkgs.python3}/bin/python3
    import json
    import os
    import signal
    import subprocess
    import sys
    import time

    THEME_LINK = os.path.expanduser("~/Pictures/Wallpapers/current-theme")
    DEFAULT_THEME_DIR = os.path.expanduser("~/Pictures/Wallpapers/miyazaki")

    def get_current_theme_dir():
        if os.path.islink(THEME_LINK):
            return os.path.realpath(THEME_LINK)
        return DEFAULT_THEME_DIR

    def get_wallpaper_for_workspace(idx):
        theme_dir = get_current_theme_dir()
        candidate = os.path.join(theme_dir, f"workspace-{idx}.png")
        if os.path.exists(candidate):
            return candidate
        candidate_jpg = os.path.join(theme_dir, f"workspace-{idx}.jpg")
        if os.path.exists(candidate_jpg):
            return candidate_jpg
        fallback = os.path.join(theme_dir, "workspace-1.png")
        if os.path.exists(fallback):
            return fallback
        return None

    class WallpaperManager:
        def __init__(self):
            self.current_idx = None
            self.current_proc = None
            self.workspace_map = {}

        def set_wallpaper(self, idx):
            if idx == self.current_idx and self.current_proc and self.current_proc.poll() is None:
                return
            wall = get_wallpaper_for_workspace(idx)
            if not wall:
                return
            new_proc = subprocess.Popen(["${pkgs.swaybg}/bin/swaybg", "-m", "fill", "-i", wall])
            time.sleep(0.08)
            if self.current_proc and self.current_proc.poll() is None:
                self.current_proc.terminate()
                try:
                    self.current_proc.wait(timeout=0.2)
                except Exception:
                    self.current_proc.kill()
            self.current_proc = new_proc
            self.current_idx = idx

        def reload_theme(self, signum=None, frame=None):
            idx = self.current_idx or 1
            self.current_idx = None
            self.set_wallpaper(idx)

        def update_workspaces(self, workspaces):
            active_idx = None
            for ws in workspaces:
                wid = ws.get("id")
                widx = ws.get("idx")
                self.workspace_map[wid] = widx
                if ws.get("is_active") and ws.get("is_focused"):
                    active_idx = widx
            if active_idx is not None:
                self.set_wallpaper(active_idx)

        def handle_workspace_activated(self, wid):
            idx = self.workspace_map.get(wid)
            if idx is not None:
                self.set_wallpaper(idx)
            else:
                try:
                    out = subprocess.check_output(["niri", "msg", "--json", "workspaces"])
                    self.update_workspaces(json.loads(out))
                except Exception:
                    pass

        def run(self):
            signal.signal(signal.SIGUSR1, self.reload_theme)
            try:
                out = subprocess.check_output(["niri", "msg", "--json", "workspaces"])
                self.update_workspaces(json.loads(out))
            except Exception as e:
                print("Initial query failed:", e)

            proc = subprocess.Popen(["niri", "msg", "--json", "event-stream"], stdout=subprocess.PIPE, text=True)
            while True:
                line = proc.stdout.readline()
                if not line:
                    break
                try:
                    event = json.loads(line)
                    if "WorkspacesChanged" in event:
                        self.update_workspaces(event["WorkspacesChanged"].get("workspaces", []))
                    elif "WorkspaceActivated" in event:
                        self.handle_workspace_activated(event["WorkspaceActivated"].get("id"))
                except Exception:
                    pass

    if __name__ == "__main__":
        wm = WallpaperManager()
        wm.run()
  '';

  # CLI tool to switch wallpaper themes easily (miyazaki, musashi, etc.)
  set-wallpaper-theme = pkgs.writeShellScriptBin "set-wallpaper-theme" ''
    THEME="$1"
    TARGET="$HOME/Pictures/Wallpapers/$THEME"
    if [ -z "$THEME" ] || [ ! -d "$TARGET" ]; then
      echo "Usage: set-wallpaper-theme <theme_name>"
      echo "Available themes in ~/Pictures/Wallpapers:"
      find "$HOME/Pictures/Wallpapers" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
      exit 1
    fi
    ln -sfn "$TARGET" "$HOME/Pictures/Wallpapers/current-theme"
    pkill -USR1 -f wallpaper-rotator || true
    echo "Switched wallpaper theme to: $THEME"
  '';
in
{
  # Link Wallpapers to ~/Pictures/Wallpapers
  home.file."Pictures/Wallpapers/ryan4yin".source = wallpapers;
  home.file."Pictures/Wallpapers/extra".source = wallpapers-extra;

  home.packages = [
    wallpaper-rotator
    set-wallpaper-theme
  ];

  # Link Niri & Hyprlock configuration
  xdg.configFile = {
    "niri/config.kdl".source = ./conf/config.kdl;
    "niri/keybindings.kdl".source = ./conf/keybindings.kdl;
    "niri/windowrules.kdl".source = ./conf/windowrules.kdl;
    "niri/spawn-at-startup.kdl".source = ./conf/spawn-at-startup.kdl;
    "hypr/hyprlock.conf".source = ./conf/hyprlock.conf;
  };

  # Terminal Emulator (Alacritty with Catppuccin Mocha)
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.95;
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
      };
    };
  };

  # Application launcher (Fuzzel)
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        prompt = "'❯ '";
        terminal = "alacritty";
        lines = 10;
        width = 35;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 5;
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "f38ba8ff";
        border = "cba6f7ff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  # Notification daemon (Mako)
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      background-color = "#1e1e2edd";
      text-color = "#cdd6f4ff";
      border-color = "#cba6f7ff";
      border-radius = 8;
      border-size = 2;
      default-timeout = 5000;
    };
  };

  # Status bar (Waybar)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        modules-left = [
          "custom/overview"
          "niri/workspaces"
          "clock"
        ];
        modules-center = [
          "niri/window"
        ];
        modules-right = [
          "custom/clipboard"
          "pulseaudio"
          "backlight"
          "battery"
          "network"
          "cpu"
          "memory"
          "tray"
          "custom/power"
        ];

        "custom/overview" = {
          format = "󰕰";
          tooltip = "Aperçu (Overview)\nClic: Afficher / Masquer l'aperçu des espaces et fenêtres";
          on-click = "niri msg action toggle-overview";
        };

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "󰮯";
            focused = "";
            default = "";
          };
        };

        "niri/window" = {
          format = "{title}";
          max-length = 45;
          rewrite = {
            "" = "Niri Desktop";
          };
        };

        clock = {
          format = " {:%H:%M - %A %d %b %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
        };

        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format = "{timeTo}\nSanté: {health}%";
        };

        network = {
          interval = 2;
          format-wifi = " {bandwidthDownBytes} 󰕒 {bandwidthUpBytes}";
          format-ethernet = "󰈀 {bandwidthDownBytes} 󰕒 {bandwidthUpBytes}";
          format-disconnected = "󰤭 Disconnected";
          tooltip-format = "{ifname} ({essid}): {ipaddr}/{cidr}\nSignal: {signalStrength}%\n󰇚 {bandwidthDownBytes} | 󰕒 {bandwidthUpBytes}";
          on-click = "nm-connection-editor";
        };

        cpu = {
          format = " {usage}%";
          on-click = "alacritty -e btop";
        };

        memory = {
          format = " {}%";
          on-click = "alacritty -e btop";
        };

        tray = {
          spacing = 10;
        };

        "custom/clipboard" = {
          format = "";
          tooltip = "Presse-papier (Historique)\nClic gauche: Sélectionner\nClic droit: Vider";
          on-click = "cliphist list | fuzzel -d | cliphist decode | wl-copy";
          on-click-right = "cliphist wipe";
        };

        "custom/power" = {
          format = "⏻";
          tooltip = "Verrouiller / Quitter";
          on-click = "hyprlock";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 13px;
        min-height: 0;
      }
      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
        border-bottom: 2px solid #cba6f7;
      }
      #workspaces {
        background-color: #313244;
        margin: 2px 4px;
        padding: 0 4px;
        border-radius: 6px;
      }
      #workspaces button {
        padding: 0 6px;
        color: #a6adc8;
        background: transparent;
        border-radius: 4px;
        border: none;
      }
      #workspaces button.focused {
        color: #cba6f7;
      }
      #workspaces button.active {
        color: #89b4fa;
      }
      #workspaces button:hover {
        background-color: #45475a;
        color: #f5e0dc;
      }
      #window {
        padding: 0 12px;
        margin: 2px 4px;
        border-radius: 6px;
        background-color: #313244;
        color: #f5c2e7;
        font-weight: bold;
      }
      #clock, #cpu, #memory, #network, #pulseaudio, #backlight, #battery, #tray, #custom-clipboard, #custom-power, #custom-overview {
        padding: 0 10px;
        margin: 2px 3px;
        border-radius: 6px;
        background-color: #313244;
      }
      #custom-overview {
        color: #cba6f7;
        font-size: 15px;
        padding: 0 10px;
      }
      #custom-overview:hover {
        background-color: #cba6f7;
        color: #1e1e2e;
      }
      #custom-clipboard {
        color: #f5c2e7;
        font-size: 14px;
        padding: 0 10px;
      }
      #custom-clipboard:hover {
        background-color: #f5c2e7;
        color: #1e1e2e;
      }
      #clock {
        color: #cba6f7;
      }
      #pulseaudio {
        color: #89b4fa;
      }
      #backlight {
        color: #f9e2af;
      }
      #battery {
        color: #a6e3a1;
      }
      #battery.charging {
        color: #94e2d5;
      }
      #battery.warning:not(.charging) {
        color: #fab387;
      }
      #battery.critical:not(.charging) {
        color: #f38ba8;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      @keyframes blink {
        to {
          background-color: #f38ba8;
          color: #1e1e2e;
        }
      }
      #network {
        color: #a6e3a1;
      }
      #cpu {
        color: #f9e2af;
      }
      #memory {
        color: #fab387;
      }
      #custom-power {
        color: #f38ba8;
        padding: 0 12px;
        font-size: 15px;
      }
      #custom-power:hover {
        background-color: #f38ba8;
        color: #1e1e2e;
      }
    '';
  };
}
