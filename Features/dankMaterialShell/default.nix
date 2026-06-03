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
    default = config.features.niri.enable;
    description = "Dank Material Shell for Niri";
  };

  config = lib.mkIf cfg.enable {

    assertions = [
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

    services.displayManager.ly = {
      enable = true;
      x11Support = false;
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
