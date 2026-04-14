{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.mySystem.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Essential system packages";
  };

  config = lib.mkIf config.mySystem.features.core.enable {
    environment.systemPackages = with pkgs; [
      wget
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
