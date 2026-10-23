{ pkgs, ... }:
{
  # Developer & SRE Tools Stack
  environment.systemPackages = with pkgs; [
    # Dev environments & isolation
    devenv

    # Python with pip, mcp[cli], fastembed, and chromadb
    (python3.withPackages (
      ps:
      with ps;
      [
        pip
        mcp
        fastembed
        chromadb
      ]
      ++ ps.mcp.optional-dependencies.cli
    ))

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
