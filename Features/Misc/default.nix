{lib, ...}: {
  imports = lib.mapAttrsToList (name: _: ./${name}) (
    lib.filterAttrs (
      name: type:
        (type == "directory")
        || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
    ) (builtins.readDir ./.)
  );
}
