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
}
