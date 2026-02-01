{ pkgs, ... }:

{
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    fish = {
      enable = true;
      generateCompletions = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
