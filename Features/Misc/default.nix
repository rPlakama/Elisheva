{lib, ...}: let
  contents = builtins.readDir ./.;
  isImportable = name: type:
    (type == "directory") || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix");
  importable = lib.filterAttrs (name: type: isImportable name type) contents;
  modulePaths = lib.mapAttrsToList (name: _: ./${name}) importable;
in {
  imports = modulePaths;
}
