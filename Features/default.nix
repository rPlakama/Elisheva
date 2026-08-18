{lib, ...}: {
  imports = lib.mapAttrsToList (name: _: ./${name}) (
    lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.)
  );
}
