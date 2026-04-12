{ pkgs, ... }:
{

  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  gnome = {
    core-apps.enable = false;
    core-developer-tools.enable = false;
    games.enable = false;
  };
  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
