{ ... }:
{
  # Don't forget to set it.
  # First make the dirs -> sudo mkdir -p ...
  # sudo chown -R rplakama:media /media
  # sudo chmod -R 2775 /media
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
