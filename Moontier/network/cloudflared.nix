{ pkgs, ... }:
{

  services.cloudflared = {
    enable = true;
  };
  environment.systemPackages = [
    pkgs.cloudflared
  ];
}
