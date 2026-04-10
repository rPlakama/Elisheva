{ lib, ... }:
let
  base_path = "d /media";
  rules_group = " 2775 nobody media - - ";
  mediaFolders = [
    "films"
    "music"
    "downloads"
    "series"
    "torrents"
  ];
  mediaUsers = [
    "rplakama"
    "qbittorrent"
    "slskd"
    "nzbget"
    "jackett"
    "readarr"
  ];
in
{
  users = {
    groups.media = { };
    users =
      (lib.genAttrs mediaUsers (name: {
        extraGroups = [ "media" ];
      }))
      // {
        jellyfin.extraGroups = [
          "video"
          "render"
          "media"
        ];
      };
  };
  systemd.tmpfiles.rules = map (folder: "${base_path}/${folder} ${rules_group}") mediaFolders;
}
