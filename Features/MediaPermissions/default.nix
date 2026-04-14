{ config, lib, ... }:

let
  cfg = config.core.features.mediaPermissions;
  user = config.core.user;

  base_path = "d /media";
  rules_group = " 2775 nobody media - - ";
  mediaFolders = [
    "films"
    "music"
    "downloads"
    "series"
    "torrents"
  ];
in
{
  options.core.features.mediaCore.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Shared media folders and group permissions";
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];

    systemd.tmpfiles.rules = map (folder: "${base_path}/${folder} ${rules_group}") mediaFolders;
  };
}
