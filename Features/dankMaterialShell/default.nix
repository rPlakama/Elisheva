{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.optionals.features.dankMaterialShell;
  user = config.core.user;
  persistEnabled = config.optionals.features.preservation.enable;
in

{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.optionals.features.dankMaterialShell.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Dank Material Shell for Niri";
    default = config.optionals.features.niri.enable;
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.niri-flake-polkit.enable = false;

    programs.dank-material-shell = {
      enable = true;
      enableCalendarEvents = false;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };

    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/${user}";
    };

    optionals.features.preservation.keepDirs.homeDirs = lib.mkIf persistEnabled [
      ".config/dank-material-shell"
    ];
  };
}
