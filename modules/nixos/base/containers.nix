{ pkgs, ... }:
{
  # Podman container runtime with Docker emulation
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman
      dockerCompat = true;
      # Required for containers under Podman-5 to talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Podman auto-completion & compose
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
