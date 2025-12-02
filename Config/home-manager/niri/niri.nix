{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./niri-outputs.nix
    ./niri-window_rules.nix
    ./niri-animations.nix
    ./niri-binds.nix
    ./niri-layout.nix
    ./niri-overview.nix
    ./dms.nix
  ];

  programs.niri = {
    settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;
      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite;
      };
      layer-rules = [
        {
          matches = [{namespace = "^quickshell$";}];
          place-within-backdrop = true;
        }
      ];
    };
  };
}
