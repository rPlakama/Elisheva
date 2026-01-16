{ ... }:
{
  services = {
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    flaresolverr = {
      enable = true;
      port = 8191;
    };
  };
}
