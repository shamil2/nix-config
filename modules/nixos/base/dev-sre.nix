{ pkgs, ... }:
{
  # Developer & SRE Tools Stack
  environment.systemPackages = with pkgs; [
    # Dev environments & isolation
    devenv

    # Kubernetes & Containers
    kubectl
    k9s
    kubernetes-helm

    # Cloud CLI
    google-cloud-sdk

    # Data manipulation & querying
    jq
    yq-go

    # Modern search & CLI utilities
    ripgrep
    fd
  ];
}
