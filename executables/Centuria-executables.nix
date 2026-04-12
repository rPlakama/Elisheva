{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
