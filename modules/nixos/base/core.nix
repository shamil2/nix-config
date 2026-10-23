{ lib, ... }:
{
  # Bootloader settings
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = lib.mkDefault 10;
    consoleMode = lib.mkDefault "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 5;

  # Hibernation resume configuration (points to swap partition)
  boot.resumeDevice = "/dev/disk/by-uuid/29b5c76e-4348-4b49-97eb-ae4f7cb38648";

  # Power management on lid close
  services.logind = {
    settings = {
      Login = {
        # Hibernate when closing the laptop lid
        HandleLidSwitch = "hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
    };
  };

  # Run dynamically linked binaries (VS Code extensions, pip/npm native wheels) & /bin/* scripts
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  # NVMe SSD periodic TRIM & Intel thermal management
  services.fstrim.enable = true;
  services.thermald.enable = true;

  # Fast compressed RAM swap & OOM desktop freeze protection
  zramSwap.enable = true;
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };
}
