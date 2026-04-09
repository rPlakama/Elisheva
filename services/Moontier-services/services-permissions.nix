{ ... }:
{
  users = {
    groups.media = { };
    users = {
      rplakama.extraGroups = [ "media" ];
      qbittorrent.extraGroups = [ "media" ];
      slskd.extraGroups = [ "media" ];
      lidarr.extraGroups = [ "media" ];
      nzbget.extraGroups = [ "media" ];
      jellyfin.extraGroups = [
        "video"
        "render"
        "media"
      ];
    };
  };
}
