{ ... }:

{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };
  services.ombi = {
    enable = true;
    openFirewall = true;
    port = 9302;
  };
}
