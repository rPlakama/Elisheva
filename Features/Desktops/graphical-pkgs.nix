{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.features.graphicalPkgs;
  user = config.core.user;
  headless = config.core.headless;
in {
  options.features.graphicalPkgs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = !headless;
      description = "Graphical Packages";
    };
    foot.theme = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Import themes for Foot";
      example = "include=path";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.helium-browser.packages.x86_64-linux.default
      vesktop
      materialgram
      nextcloud-client
      jellyfin-desktop
      firefox-beta
      foot
      mpv
      ripdrag
      obsidian
      kdePackages.okular
      gnome-disk-utility
      motrix-next
      easyeffects
    ];

    hjem.users.${user} = {
      files.".config/foot/foot.ini".text =
        ''
          [main]
          dpi-aware=false
          font=CaskaydiaCove Nerd Font Mono:size=9
        ''
        + "\n"
        + (lib.concatStringsSep "\n" cfg.foot.theme);
    };
  };
}
