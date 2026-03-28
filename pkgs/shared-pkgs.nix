{
  pkgs,
  lib,
  isDesktop,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fzf
    dust
    git
    jq
  ] ++ lib.optionals isDesktop [
    age
    sops
    papirus-folders
    papirus-icon-theme
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
