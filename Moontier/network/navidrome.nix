{ ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    group = "users";
    settings = {
      MusicFolder = "/media/music/library";
    };
  };
}
