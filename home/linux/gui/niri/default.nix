{
  pkgs,
  wallpapers,
  wallpapers-extra,
  ...
}:
let
  # Wallpaper rotation daemon using swaybg
  wallpaper-rotator = pkgs.writeShellScriptBin "wallpaper-rotator" ''
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    INTERVAL=300 # 5 minutes

    while true; do
      # Collect all images from the wallpaper directories and shuffle
      mapfile -t images < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "default_wallpaper" | shuf)
      if [ ''${#images[@]} -eq 0 ]; then
        sleep 10
        continue
      fi
      for img in "''${images[@]}"; do
        # Start new swaybg instance with selected wallpaper
        ${pkgs.swaybg}/bin/swaybg -m fill -i "$img" &
        NEW_PID=$!
        sleep 1
        # Kill previous swaybg instances
        ${pkgs.procps}/bin/pgrep swaybg | ${pkgs.gnugrep}/bin/grep -v "^$NEW_PID$" | ${pkgs.findutils}/bin/xargs -r kill 2>/dev/null || true
        sleep "$INTERVAL"
      done
    done
  '';
in
{
  # Link Wallpapers to ~/Pictures/Wallpapers
  home.file."Pictures/Wallpapers/ryan4yin".source = wallpapers;
  home.file."Pictures/Wallpapers/extra".source = wallpapers-extra;

  home.packages = [
    wallpaper-rotator
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
          "niri/workspaces"
          "clock"
        ];
        modules-center = [
          "niri/window"
        ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "battery"
          "network"
          "cpu"
          "memory"
          "tray"
          "custom/power"
        ];

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
          format-wifi = " {signalStrength}%";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰤭 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
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
      #clock, #cpu, #memory, #network, #pulseaudio, #backlight, #battery, #tray, #custom-power {
        padding: 0 10px;
        margin: 2px 3px;
        border-radius: 6px;
        background-color: #313244;
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
