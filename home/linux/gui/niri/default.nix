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

  # Secret-filtering clipboard & primary-selection store wrapper for cliphist
  cliphist-store-safe = pkgs.writeScriptBin "cliphist-store-safe" ''
    #!${pkgs.python3}/bin/python3
    import fcntl
    import hashlib
    import math
    import os
    import re
    import subprocess
    import sys
    import time

    is_primary = "--primary" in sys.argv[1:]
    raw = sys.stdin.buffer.read()
    if not raw:
        sys.exit(0)

    # For mouse primary selection, debounce 250ms so intermediate drag states are ignored
    if is_primary:
        time.sleep(0.25)
        try:
            cmd = ["${pkgs.wl-clipboard}/bin/wl-paste", "--primary", "--no-newline"]
            current = subprocess.check_output(cmd, stderr=subprocess.DEVNULL, timeout=1)
            if current.rstrip(b"\r\n") != raw.rstrip(b"\r\n"):
                sys.exit(0)
        except Exception:
            pass

    # Check Wayland clipboard MIME types for password manager hints
    try:
        mime_cmd = ["${pkgs.wl-clipboard}/bin/wl-paste", "--list-types"]
        if is_primary:
            mime_cmd.insert(1, "--primary")
        mimes = subprocess.check_output(mime_cmd, stderr=subprocess.DEVNULL, text=True, timeout=1).lower()
        secret_mimes = (
            "x-kde-passwordmanagerhint",
            "x-sensitive",
            "password",
            "secret",
            "bitwarden",
            "keepass",
            "1password",
        )
        if any(m in mimes for m in secret_mimes):
            sys.exit(0)
    except Exception:
        pass

    text = raw.decode("utf-8", errors="ignore").strip()
    if len(text) < 2 or len(text) > 100000:
        sys.exit(0)

    # Ignore internal menu action labels
    if text.startswith(("󰆴 ", "󰃢 ")):
        sys.exit(0)

    # Filter out known secret formats (private keys, API tokens, JWTs, password assignments)
    SECRET_PATTERNS = [
        r"-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----",
        r"-----BEGIN PGP MESSAGE-----",
        r"\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{20,}\b",
        r"\bgithub_pat_[A-Za-z0-9_]{20,}\b",
        r"\bglpat-[A-Za-z0-9_-]{20,}\b",
        r"\bsk-(proj-|ant-)?[A-Za-z0-9_-]{20,}\b",
        r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b",
        r"\bAKIA[0-9A-Z]{16}\b",
        r"\bAIza[0-9A-Za-z_-]{35}\b",
        r"\beyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}\b",
        r"(?i)\b(bearer|password|passwd|secret|api[_-]?key|client[_-]?secret|private[_-]?key|access[_-]?token|auth[_-]?token)\s*[:=]\s*['\"]?\S{6,}",
    ]
    for pat in SECRET_PATTERNS:
        if re.search(pat, text):
            sys.exit(0)

    # Heuristic: filter single-token high-entropy strings that look like passwords
    if " " not in text and "\n" not in text and "\t" not in text and 10 <= len(text) <= 64:
        if not text.startswith(("http://", "https://", "/", "~/", "./")) and "/" not in text:
            classes = sum([
                bool(re.search(r"[a-z]", text)),
                bool(re.search(r"[A-Z]", text)),
                bool(re.search(r"[0-9]", text)),
                bool(re.search(r"[^a-zA-Z0-9._-]", text)),
            ])
            freq = {ch: text.count(ch) / len(text) for ch in set(text)}
            entropy = -sum(p * math.log2(p) for p in freq.values())
            if classes >= 3 and entropy >= 3.3:
                sys.exit(0)

    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    lock_path = os.path.join(runtime_dir, "cliphist-safe.lock")
    hash_path = os.path.join(runtime_dir, "cliphist-last.sha256")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()

    with open(lock_path, "w") as lock_file:
        fcntl.flock(lock_file, fcntl.LOCK_EX)
        try:
            if os.path.exists(hash_path):
                with open(hash_path, "r") as hf:
                    if hf.read().strip() == digest:
                        sys.exit(0)
        except Exception:
            pass
        with open(hash_path, "w") as hf:
            hf.write(digest)

    # Sync mouse primary selection to regular clipboard so Ctrl+V works everywhere
    if is_primary:
        try:
            p_copy = subprocess.Popen(["${pkgs.wl-clipboard}/bin/wl-copy"], stdin=subprocess.PIPE)
            p_copy.communicate(text.encode("utf-8"), timeout=1)
        except Exception:
            pass

    proc = subprocess.Popen(
        ["${pkgs.cliphist}/bin/cliphist", "-min-store-length", "2", "store"],
        stdin=subprocess.PIPE,
    )
    proc.communicate(text.encode("utf-8"))

    # Show a lightweight 1.5s popup toast confirming the text was copied
    preview = " ".join(text.split())
    if len(preview) > 48:
        preview = preview[:48] + "…"
    subprocess.Popen(
        [
            "${pkgs.libnotify}/bin/notify-send",
            "-a", "Clipboard",
            "-t", "1500",
            "-u", "low",
            "-h", "string:x-canonical-private-synchronous:clipboard",
            "󰅌 Copié",
            preview,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
  '';

  # Interactive Fuzzel viewer/selector for copied & selected text history
  # - Enter: copy selected line
  # - Delete or Ctrl+D: delete highlighted line directly and stay in menu
  # - Ctrl+Shift+D: wipe entire history
  clipboard-menu = pkgs.writeShellScriptBin "clipboard-menu" ''
    NOTIFY="${pkgs.libnotify}/bin/notify-send -a Clipboard -t 1500 -u low -h string:x-canonical-private-synchronous:clipboard"
    DELETE_OPT="󰆴 Supprimer une ligne... (ou touche Suppr / Ctrl+D)"
    WIPE_OPT="󰃢 Vider tout l'historique (ou Ctrl+Shift+D)"

    run_delete_mode() {
      while true; do
        LIST="$(${pkgs.cliphist}/bin/cliphist list)"
        [ -z "$LIST" ] && exit 0
        SELECTION="$(printf '%s\n' "$LIST" | ${pkgs.fuzzel}/bin/fuzzel --dmenu \
          --prompt="󰆴 Supprimer ❯ " \
          --placeholder="Entrée / Suppr / Ctrl+D: supprimer la ligne  |  Échap: retour" \
          --width=70 --lines=15 \
          --override="key-bindings.delete-next=none" \
          --override="key-bindings.custom-1=Delete Control+d")"
        STATUS=$?
        if [ $STATUS -eq 0 ] || [ $STATUS -eq 10 ]; then
          if [ -n "$SELECTION" ]; then
            printf '%s' "$SELECTION" | ${pkgs.cliphist}/bin/cliphist delete
            rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cliphist-last.sha256"
            $NOTIFY "󰆴 Ligne supprimée" "Entrée retirée du presse-papier"
          fi
        else
          break
        fi
      done
    }

    case "$1" in
      --delete|-d)
        run_delete_mode
        exit 0
        ;;
      --wipe|-w)
        ${pkgs.cliphist}/bin/cliphist wipe
        rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cliphist-last.sha256"
        $NOTIFY "󰃢 Presse-papier vidé" "Tout l'historique a été effacé"
        exit 0
        ;;
    esac

    while true; do
      LIST="$(${pkgs.cliphist}/bin/cliphist list)"
      if [ -z "$LIST" ]; then
        $NOTIFY "󰅌 Presse-papier vide" "Aucun texte copié pour le moment"
        exit 0
      fi

      SELECTION="$(printf '%s\n%s\n%s\n' "$LIST" "$DELETE_OPT" "$WIPE_OPT" | ${pkgs.fuzzel}/bin/fuzzel --dmenu \
        --prompt="󰅌 Paste ❯ " \
        --placeholder="Entrée: copier | Suppr / Ctrl+D: supprimer ligne | Ctrl+Shift+D: vider" \
        --width=70 --lines=15 \
        --override="key-bindings.delete-next=none" \
        --override="key-bindings.custom-1=Delete Control+d" \
        --override="key-bindings.custom-2=Control+Shift+d")"
      STATUS=$?

      if [ $STATUS -eq 10 ]; then
        # Delete / Ctrl+D pressed on highlighted line -> delete it and refresh menu
        if [ -n "$SELECTION" ] && [ "$SELECTION" != "$DELETE_OPT" ] && [ "$SELECTION" != "$WIPE_OPT" ]; then
          printf '%s' "$SELECTION" | ${pkgs.cliphist}/bin/cliphist delete
          rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cliphist-last.sha256"
          $NOTIFY "󰆴 Ligne supprimée" "Entrée retirée du presse-papier"
        fi
        continue
      elif [ $STATUS -eq 11 ] || [ "$SELECTION" = "$WIPE_OPT" ]; then
        ${pkgs.cliphist}/bin/cliphist wipe
        rm -f "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cliphist-last.sha256"
        $NOTIFY "󰃢 Presse-papier vidé" "Tout l'historique a été effacé"
        break
      elif [ $STATUS -eq 0 ] && [ "$SELECTION" = "$DELETE_OPT" ]; then
        run_delete_mode
        continue
      elif [ $STATUS -eq 0 ] && [ -n "$SELECTION" ]; then
        DECODED="$(printf '%s' "$SELECTION" | ${pkgs.cliphist}/bin/cliphist decode)"
        printf '%s' "$DECODED" | ${pkgs.python3}/bin/python3 -c '
import hashlib, os, sys
text = sys.stdin.read().strip()
rt = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
open(os.path.join(rt, "cliphist-last.sha256"), "w").write(hashlib.sha256(text.encode()).hexdigest())
'
        printf '%s' "$DECODED" | ${pkgs.wl-clipboard}/bin/wl-copy
        printf '%s' "$DECODED" | ${pkgs.wl-clipboard}/bin/wl-copy --primary
        $NOTIFY "󰅌 Prêt à coller" "$(printf '%s' "$DECODED" | tr '\n' ' ' | cut -c1-48)"
        break
      else
        break
      fi
    done
  '';
in
{
  # Link Wallpapers to ~/Pictures/Wallpapers
  home.file."Pictures/Wallpapers/ryan4yin".source = wallpapers;
  home.file."Pictures/Wallpapers/extra".source = wallpapers-extra;

  home.packages = [
    wallpaper-rotator
    set-wallpaper-theme
    cliphist-store-safe
    clipboard-menu
  ];

  # Link Niri & Hyprlock configuration
  xdg.configFile = {
    "niri/config.kdl".source = ./conf/config.kdl;
    "niri/keybindings.kdl".source = ./conf/keybindings.kdl;
    "niri/windowrules.kdl".source = ./conf/windowrules.kdl;
    "niri/spawn-at-startup.kdl".source = ./conf/spawn-at-startup.kdl;
    "hypr/hyprlock.conf".source = ./conf/hyprlock.conf;
  };

  # Terminal Emulator (Kitty with Catppuccin Mocha & native image protocol)
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11.0;
    };
    settings = {
      shell = "zsh";
      copy_on_select = "clipboard";
      window_padding_width = 10;
      background_opacity = "0.95";
      confirm_os_window_close = 0;
      enable_audio_bell = false;

      # Catppuccin Mocha palette
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";

      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#f5e0dc";

      active_border_color = "#b4befe";
      inactive_border_color = "#6c7086";
      bell_border_color = "#f9e2af";

      active_tab_foreground = "#11111b";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111b";

      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";
    };
  };

  # Application launcher (Fuzzel)
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        prompt = "'❯ '";
        terminal = "kitty";
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

  # Automatic idle lock & screen power management (Swayidle + Hyprlock)
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${pkgs.hyprlock}/bin/hyprlock";
      lock = "${pkgs.hyprlock}/bin/hyprlock";
    };
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.hyprlock}/bin/hyprlock";
      }
      {
        timeout = 900;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
    ];
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
          on-click = "kitty -e btop";
        };

        memory = {
          format = " {}%";
          on-click = "kitty -e btop";
        };

        tray = {
          spacing = 10;
        };

        "custom/clipboard" = {
          format = "";
          tooltip = "Presse-papier & Sélections (Sans secrets)\nClic gauche (Mod+V): Sélectionner\nClic droit (Mod+Ctrl+V): Vider";
          on-click = "clipboard-menu";
          on-click-right = "clipboard-menu --wipe";
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
