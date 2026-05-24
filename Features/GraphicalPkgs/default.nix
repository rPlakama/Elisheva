{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.graphicalPkgs;
  user = config.core.user;
  niriEnabled = config.features.niri.enable;

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
          hash = "sha256-TuFTXDrgLGJD0jaTeo66eHpHLjHKYofrZwn61aQLArY=";
        };
      });
in
{
  options.features.graphicalPkgs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Graphical Packages";
  };

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.home = [
      ".config/vesktop"
      ".config/foot"
    ];

    environment.systemPackages = with pkgs; [
      vesktop-with-keybinds
      materialgram
      nextcloud-client
      foot
      mpv
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
