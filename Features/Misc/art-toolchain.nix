{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  featureCall = config.features;
in
{

  imports = [
    inputs.nix-craftapps.nixosModules.default
  ];
  options.features.art-toolchain.enable = lib.mkEnableOption "Art-tool kit";

  config = lib.mkIf featureCall.art-toolchain.enable {
    environment.systemPackages = with pkgs; [
      krita
      blender
    ];
    programs.craftapps = {
      enable = true;
      apps = {
        photocraft.enable = true;
      };
    };
  };
}
