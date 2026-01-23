{ ... }:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "users";
  };
}
