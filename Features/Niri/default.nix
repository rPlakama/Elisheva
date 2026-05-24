{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.features.niri;
  user = config.core.user;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    { nixpkgs.overlays = [ inputs.niri.overlays.niri ]; }
  ];

  options.features.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Niri Configuration";
    };
    ppd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow ppd";
      };
    };
    VariantKB = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Keyboard Variant";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "br";
      description = "Keyboard layout";
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
  };
}
