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
  persistEnabled = config.optionals.features.preservation.enable;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    { nixpkgs.overlays = [ inputs.niri.overlays.niri ]; }
  ];

  options.optionals.features.niri = {
    enable = lib.mkOption {
      description = "Niri Configuration";
      type = lib.types.bool;
      default = false;
    };
    ppd = {
      enable = lib.mkOption {
        description = "Allow ppd";
        type = lib.types.bool;
        default = false;
      };
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

    programs = {
      niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
    };

    environment.systemPackages = with pkgs; [

      papers
      nautilus
      loupe
      xwayland-satellite
      libnotify
      papirus-folders
      papirus-icon-theme
      volantes-cursors
      wl-clipboard
      pulseaudio

    ];

    services = lib.mkIf (!cfg.ppd.enable) {
      power-profiles-daemon.enable = lib.mkForce false; # <- Its get enabled by dms
    };

    hjem.users.${user} = {
      files.".config/niri/config.kdl".text =
        builtins.replaceStrings [ "@keyboardLayout@" "@Variant@" ] [ cfg.keyboardLayout cfg.VariantKB ]
          (builtins.readFile ./config.kdl);
    };

    optionals.features.preservation.keepDirs.homeDirs = lib.mkIf persistEnabled [
      ".config/niri"
    ];
  };
}
