{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.features.dankMaterialShell;
  user = config.core.user;
in

{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.features.dankMaterialShell.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.features.niri.enable;
    description = "Dank Material Shell for Niri";
  };

  config = lib.mkIf cfg.enable {

    assertions = [{
      assertion = config.features.niri.enable;
      message = "dankMaterialShell requires niri";
    }];

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
  };
}
