{ config, lib, ... }:

let
  cfg = config.features.mediaPermissions;
  user = config.core.user;

  base_path = "/media";
  mediaFolders = [
    "films"

    "music"
    "music/library"
    "music/downloads"

    # To be moved.
    "mangas/local"
    "mangas/download"
    "fanfics"
    "fanfics/download"
    "mangas"
    "novels"
    "books"
    # Ends here.

    "literature"
    "literature/novels"
    "literature/books"
    "literature/articles"
    "literature/mangas"

    "downloads"
    "series"
    "torrents"
  ];
in
{
  options.features.mediaPermissions.enable = lib.mkEnableOption "Shared media folders and group permissions";

  config = lib.mkIf cfg.enable {
    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];

    systemd.tmpfiles.rules = builtins.concatMap (folder: [
      "d ${base_path}/${folder} 2775 nobody media - -" # directory exists
      "Z ${base_path}/${folder} 2775 nobody media - -" # Recursively permissions
    ]) mediaFolders;
  };
}
