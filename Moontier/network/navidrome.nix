{ ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    group = "users";
    settings = {
      MusicFolder = "/mnt/@media/music/library";
    };
  };
}
