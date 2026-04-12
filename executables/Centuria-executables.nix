{ pkgs, ... }:
{

  nix.settings = {
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };
  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic = {
      enable = true;
      xwayland.enable = true;
    };
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
