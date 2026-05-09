{
  config,
  lib,
  pkgs,
  ...
}:

let
  vesktop-with-keybinds =
    (pkgs.vesktop.override {
      electron_40 = pkgs.electron_41;
    }).overrideAttrs
      (old: rec {
        src = pkgs.fetchFromGitHub {
          owner = "Vencord";
          repo = "Vesktop";
          rev = "e6954304f79cd7e4247ad1c49ec1a308403f8779";
          hash = "sha256-23stIKkoAP+5atym3suYttSirEKbBJ+g7F8V7YdjWfM=";
        };
        pnpmDeps = old.pnpmDeps.override {
          inherit src;
          hash = "sha256-nOwl/e5lL8UGjwUexm/EiA7cPmWYif9PHwa0vAX5VbM=";
        };
      });
  cfg = config.optionals.features.graphicalPkgs;
  user = config.core.user;
  niriEnabled = config.optionals.features.niri.enable;
in
{
  options.optionals.features.graphicalPkgs.enable = lib.mkOption {
    description = "Graphical Packages";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      #vesktop
      vesktop-with-keybinds
      firefox
      materialgram
      nextcloud-client
      foot
      zed-editor
      ripdrag
      helium
    ];

    hjem.users.${user} = {
      files.".config/foot/foot.ini".text = ''
        [main]
        dpi-aware=false
        font=CaskaydiaCove Nerd Font Mono:size=9
      ''
      + lib.optionalString niriEnabled ''
        include=/home/${user}/.config/foot/dank-colors.ini
      '';
    };
  };
}
