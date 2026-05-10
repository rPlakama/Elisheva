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
        Alt+F10 { spawn-sh "gsr-ui-cli replay-save; paplay /run/current-system/sw/share/sounds/freedesktop/stereo/camera-shutter.oga; DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus notify-send 'Replay Saved' 'Clip Saved!' -i camera"; }
        Alt+F11 { spawn-sh "gsr-ui-cli replay-save-1-min; paplay /run/current-system/sw/share/sounds/freedesktop/stereo/camera-shutter.oga; DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus notify-send 'Replay Saved' 'Clip Saved!' -i camera"; }
      ''
    else
      "";
  gsrWindowRule =
    if usesGpuScreenRecorder then
      ''
         window-rule {
            match app-id="gsr-ui"
            match title="gsr ui"
            opacity 0.420000
            open-floating true
            default-floating-position x=0.5 y=0.5
        } ''
    else
      "";

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
      pulseaudio

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
        builtins.replaceStrings
          [ "@keyboardLayout@" "@Variant@" "@gsrBinds@" "@gsrWindowRule@" ]
          [ cfg.keyboardLayout cfg.VariantKB gsrBinds gsrWindowRule ]
          (builtins.readFile ./config.kdl);
    };
  };
}
