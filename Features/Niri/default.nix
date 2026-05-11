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
  usesGpuScreenRecorder = config.optionals.features.gpuScreenRecorder.enable;

  gsrBinds =
    if usesGpuScreenRecorder then
      ''
        Mod+z { spawn-sh "gsr-ui"; }
      ''
    else
      "";
  gsrWindowRule =
    if usesGpuScreenRecorder then
      ''
         window-rule {
            match app-id="gsr-notify"
            match title="gsr notify"
            default-floating-position x=10 y=10 relative-to="top-left"
            open-focused false
        } ''
    else
      "";

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

    services = {
      power-profiles-daemon.enable = lib.mkForce false; # <- SCX
    };

    hjem.users.${user} = {
      files.".config/niri/config.kdl".text =
        builtins.replaceStrings
          [ "@keyboardLayout@" "@Variant@" "@gsrBinds@" "@gsrWindowRule@" ]
          [ cfg.keyboardLayout cfg.VariantKB gsrBinds gsrWindowRule ]
          (builtins.readFile ./config.kdl);
    };
  };
}
