{lib, ...}: let
  contents = builtins.readDir ./.;
  # Only dirs
  featureDirs = lib.filterAttrs (name: type: type == "directory") contents;
  # Auto mapping
  featurePaths = lib.mapAttrsToList (name: type: ./${name}) featureDirs;
in {
  imports = featurePaths;
}
