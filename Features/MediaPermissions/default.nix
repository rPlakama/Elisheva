{ config, lib, ... }:

let
  cfg = config.core.features.mediaPermissions;
  user = config.core.user;

  base_path = "/media";
  mediaFolders = [
    "films"
    "music"
    "mangas"
    "novels"
    "downloads"
    "series"
    "torrents"
  ];
in
{
  options.core.features.mediaPermissions.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Shared media folders and group permissions";
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];

    systemd.tmpfiles.rules = builtins.concatMap (folder: [
      "d ${base_path}/${folder} 2775 nobody media - -" # directory exists
      "Z ${base_path}/${folder} 2775 nobody media - -" # Recursively permissions
    ]) mediaFolders;
  };
}
