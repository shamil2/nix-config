{ lib, ... }:
{
  nixosSystem = import ./nixosSystem.nix;

  # Path relative to the root of the configuration repository
  relativeToRoot = lib.path.append ../.;

  # Recursively/automatically scan directory for .nix files and directories containing default.nix (excluding current default.nix)
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
          (_type == "directory" && builtins.pathExists (path + "/${name}/default.nix"))
          || (
            (name != "default.nix")
            && (lib.strings.hasSuffix ".nix" name)
          )
        ) (builtins.readDir path)
      )
    );
}
