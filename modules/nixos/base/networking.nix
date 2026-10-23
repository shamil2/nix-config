{ lib, ... }:
{
  # Enable NetworkManager
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  # Enable stateful firewall (default-deny inbound, allows all outbound)
  networking.firewall.enable = true;
}
