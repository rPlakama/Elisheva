{
  config,
  inputs,
  lib,
  ...
}:
let
  featureCall = config.features;
in
{

  imports = [
    inputs.nix-craftapps.nixosModules.default
  ];
  options.features.artcraft.enable = lib.mkEnableOption "Artcraft tool-chain";

  config = lib.mkIf featureCall.artcraft.enable {
    programs.craftapps = {
      enable = true;
      apps = {
        photocraft.enable = true;
      };
    };
  };
}
