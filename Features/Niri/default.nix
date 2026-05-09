{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.optionals.features.niri;
  user = config.core.user;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.dms.nixosModules.dank-material-shell
    { nixpkgs.overlays = [ inputs.niri.overlays.niri ]; }
  ];

  options.optionals.features.niri = {
    enable = lib.mkOption {
      description = "Niri Configuration";
      type = lib.types.bool;
      default = false;
    };
    VariantKB = lib.mkOption {
      description = "Keyboard Variant";
      type = lib.types.str;
      default = "";
    };

    keyboardLayout = lib.mkOption {
      description = "Keyboard layout";
      type = lib.types.str;
      default = "br";
    };
  };
  config = lib.mkIf cfg.enable {

    systemd.user.services.niri-flake-polkit.enable = false;

    programs = {
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
      dank-material-shell = {
        enable = true;
        enableCalendarEvents = false;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      papers
      nautilus
      loupe
      xwayland-satellite
      papirus-folders
      papirus-icon-theme
      volantes-cursors
      wl-clipboard

    ];

    services = {
      power-profiles-daemon.enable = lib.mkForce false;
      displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/${user}";
      };
    };

    hjem.users.${user} = {
      files.".config/niri/config.kdl".text =

        builtins.replaceStrings [ "@keyboardLayout@" ] [ cfg.keyboardLayout ] builtins.replaceStrings
          [ "@Variant@" ]
          [ cfg.keyboardLayout ]
          (builtins.readFile ./config.kdl);
    };
  };
}
