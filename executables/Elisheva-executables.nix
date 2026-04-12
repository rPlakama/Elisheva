{ pkgs, ... }:
{

  systemd.user.services.niri-flake-polkit.enable = false; # <-- DMS.
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

}
