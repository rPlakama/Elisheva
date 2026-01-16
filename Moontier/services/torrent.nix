{ ... }:
{
  services.deluge = {
    enable = true;
    group = "users";

    web = {
      enable = true;
      openFirewall = true;
      port = 9091;
    };

  };
}
