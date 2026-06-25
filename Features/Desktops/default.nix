{
  lib,
  ...
}:

let
  contents = builtins.readDir ./.;
  isImportable =
    name: type:
    (type == "directory") || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix");
  importable = lib.filterAttrs (name: type: isImportable name type) contents;
  modulePaths = lib.mapAttrsToList (name: _: ./${name}) importable;
in
{
  imports = modulePaths;

  boot.consoleLogLevel = 0;
  services.displayManager.ly = {
    enable = true;
    settings = {
      default_input = "password";
      bigclock = true;
      animate = true;
      hide_borders = true;
    };
  };
}
