{
  isDesktop,
  isCenturia,
  pkgs,
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
      enable = isCenturia;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
