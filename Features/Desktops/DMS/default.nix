{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let

  user = config.core.user;
  featureCall = config.features;
  inherit (lib)
    mkOption
    mkIf
    types
    ;
  inherit (types) bool;

in

{

  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.features.dms-shell = {
    enable = mkOption {
      type = bool;
      default = featureCall.niri.dms-shell.enabled;
      description = "dms-shell module";
    };
  };

  config = mkIf featureCall.dms-shell.enable {

    features.niri.dms-shell.import = ''
      include "dmsBinds.kdl"
    '';

    hjem.users.${user}.xdg.config.files."niri/dmsBinds.kdl".source = ./dmsBinds.kdl;

    programs.dms-shell = {
      enable = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;

    };
  };
}
