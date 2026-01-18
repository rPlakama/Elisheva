{ pkgs, ... }:
{

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    intel-gpu-tools
  ];

  systemd.services.jellyfin.serviceConfig.BindReadOnlyPaths = [
    "/home/rplakama/Music:/media/Music"
  ];
}
