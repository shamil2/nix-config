{ pkgs, ... }:
{
  security.sudo.enable = true;
  security.polkit = {
    enable = true;
    # Allow users to enroll and verify their own fingerprints without a graphical polkit prompt
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("net.reactivated.fprint.device.") == 0 && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # Fingerprint reader daemon
  services.fprintd.enable = true;

  # Enable PAM fingerprint authentication for sudo and polkit
  # (Hyprlock has native parallel fprintd support configured in hyprlock.conf)
  security.pam.services = {
    sudo.fprintAuth = true;
    polkit-1.fprintAuth = true;
  };

  # Polkit authentication agent for GUI sessions
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
