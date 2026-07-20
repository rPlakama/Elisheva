{
  config,
  lib,
  ...
}:
let
  cfg = config.features.mediaPermissions;
  user = config.core.user;
  base_path = "/media";
  mediaFolders = [
    "films"

    "music"
    "music/library"
    "music/downloads"

    "literature"
    "literature/novels"
    "literature/books"
    "literature/articles"
    "literature/mangas"
    "literature/studies"

    "downloads"
    "series"
    "torrents"
  ];
  allMediaPaths = map (f: "${base_path}/${f}") mediaFolders;
in
{
  options.features.mediaPermissions = {
    enable = lib.mkEnableOption "Shared media folders and group permissions";
    writableServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Systemd services that need ReadWritePaths on all media folders";
    };
  };
  config = lib.mkIf cfg.enable {
    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];
    systemd.tmpfiles.rules = builtins.concatMap (folder: [
      "d ${base_path}/${folder} 2775 nobody media - -"
      "Z ${base_path}/${folder} 2775 nobody media - -"
    ]) mediaFolders;
    systemd.services = lib.mkMerge (
      map (svc: {
        ${svc}.serviceConfig.ReadWritePaths = allMediaPaths;
      }) cfg.writableServices
    );
  };
}
