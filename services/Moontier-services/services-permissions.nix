{ ... }:
{
  users = {
    groups.media = { };
    users = {
      rplakama.extraGroups = [ "media" ];
      jellyfin.extraGroups = [ "media" ];
      deluge.extraGroups = [ "media" ];
      slskd.extraGroups = [ "media" ];
      lidarr.extraGroups = [ "media" ];
      nzbget.extraGroups = [ "media" ];
    };
  };
}
