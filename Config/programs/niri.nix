{ config, pkgs, ... }:
{
  systemd.user.services.niri-flake-polkit.enable = false;
  programs.niri = {
    enable = config.networking.hostName == "Centuria" || config.networking.hostName == "Elisheva";
    package = pkgs.niri-unstable;
  };
}
