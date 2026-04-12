{ pkgs, ... }:
{

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
  };
  programs = {
    gamescope.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
