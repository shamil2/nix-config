{ lib, ... }:
{
  # Enable NetworkManager
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
}
