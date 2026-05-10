{
  config,
  lib,
  inputs,
  ...
}:
let
  cfgNiri = config.optionals.features.niri;
  cfgHypr = config.optionals.features.hypr;
  user = config.core.user;
in
{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  config = lib.mkIf (cfgNiri.enable || cfgHypr.enable) {

    systemd.user.services.niri-flake-polkit.enable = false; # We use DMS polkit.

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
