{
  pkgs,
  ...
}:
{
  systemd.user.services.niri-flake-polkit.enable = false; # <-- DMS.

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
