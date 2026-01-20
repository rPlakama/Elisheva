{ ... }:

{
  services.lidarr = {
    enable = true;
    group = "users";
    openFirewall = true;
  };
}
