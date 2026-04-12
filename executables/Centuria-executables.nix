{ pkgs, ... }:
{
  services.desktopManager.gnome.enable = true;
  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
