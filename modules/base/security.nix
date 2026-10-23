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

  # Firmware security updates (LVFS)
  services.fwupd.enable = true;

  # Kernel & network security hardening (safe for desktop, containers, and login)
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
  };
}
