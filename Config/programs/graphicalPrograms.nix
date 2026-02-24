{
  isDesktop,
  pkgs,
  config,
  ...
}:
{
  systemd.user.services.niri-flake-polkit.enable = false;
  programs = {
    niri = {
      enable = isDesktop;
      package = pkgs.niri-unstable;
    };
    firefox.enable = isDesktop;
    steam = {
      enable = config.networking.hostName == "Centuria";
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
