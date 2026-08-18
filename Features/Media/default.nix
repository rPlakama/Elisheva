{
  config,
  pkgs,
  lib,
  ...
}:
let
  featureCall = config.features;
in
{
  imports = lib.mapAttrsToList (name: _: ./${name}) (
    lib.filterAttrs (
      name: type:
      (type == "directory") || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
    ) (builtins.readDir ./.)
  );

  # Music-library tooling only makes sense on hosts actually running media services.
  environment.systemPackages = lib.mkIf featureCall.mediaPermissions.enable (
    with pkgs;
    [
      exiftool
      ffmpeg-full
      opustags
      opus-tools
      flac2all
      imagemagick
    ]
  );
}
