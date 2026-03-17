{ ... }:
{

  # Don't forget to set it.
  # sudo chown -R rplakama:media /media
  # sudo chmod -R 2775 /media
  users = {
    groups.media = { };
    users = {
      rplakama.extraGroups = [ "media" ];
      jellyfin.extraGroups = [ "media" ];
      kavita.extraGroups = [ "media" ];
      deluge.extraGroups = [ "media" ];
    };
  };
}
