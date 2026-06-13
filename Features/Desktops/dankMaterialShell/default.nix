{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.features.dankMaterialShell;
  user = config.core.user;
in

{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.features.dankMaterialShell.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.features.niri.DMSEnabled;
    description = "Dank Material Shell for Niri";
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = !config.features.niri.NoctaliaEnabled;
        message = "Shall not run two Desktop Shells at same time, choose (Err DMS / Noctalia )";
      }

      {
        assertion = config.features.niri.enable;
        message = "dankMaterialShell requires niri";
      }
    ];

    hjem.users.${user}.files.".config/niri/DMS.kdl".source = ./DMS.kdl;

    features = {
      graphicalPkgs.foot.theme = [
        "include=/home/${user}/.config/foot/dank-colors.ini"
      ];

      neovim.extraInit = [
        ''vim.cmd.colorscheme("dms")''
      ];

      niri.importDMS = ''include "DMS.kdl"'';
      preservation.home.directories = [
        ".config/DankMaterialShell"
        ".config/niri"
        ".config/gtk-4.0"
        ".config/gtk-3.0"
        ".config/dconf"
        ".config/colors"
      ];
    };

    programs.dank-material-shell = {
      enable = true;
      enableCalendarEvents = false;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
