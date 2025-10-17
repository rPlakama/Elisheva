{ inputs, pkgs, ... }:
{
  # -- Utils for Systm -- #
  environment.systemPackages = with pkgs; [
    # -- Core CLI Utilities -- #
    bat
    fd
    ripgrep
    # -- File & Archive Management -- #
    p7zip
    yazi
    ripdrag
    # -- Desktop & Wayland Integration -- #
    mate.mate-polkit
    # -- Clipboard -- #
    cliphist
    wl-clip-persist
    wl-clipboard

    git
  ];

  # -- Font's -- #
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];
}
