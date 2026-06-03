{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.features.dankMaterialShell;
in

{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.features.dankMaterialShell.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.features.niri.DMSEnabled;
    description = "Dank Material Shell for Niri";
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = !config.features.niri.NoctaliaEnabled;
        message = "Shall not run two Desktop Shells at same time, choose (Err DMS / Noctalia )";
      }

      {
        assertion = config.features.niri.enable;
        message = "dankMaterialShell requires niri";
      }
    ];

    systemd.user.services.niri-flake-polkit.enable = false;
    features.preservation.persistDirs.home = [
      ".config/DankMaterialShell"
      ".config/niri"
      ".config/gtk-4.0"
      ".config/gtk-3.0"
      ".config/dconf"
    ];

    boot.consoleLogLevel = 0;
    services.displayManager.ly = {
      enable = true;
      settings = {
        default_input = "password";
      };
    };

    programs.dank-material-shell = {
      enable = true;
      enableCalendarEvents = false;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
