{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.core.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Essential system packages";
  };

  config = lib.mkIf config.core.features.core.enable {
    environment.systemPackages = with pkgs; [
      wget
      age
      sops
      git
      unzip
      dust
      jq
      fd
    ];
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];
  };
}
