{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bat
    fd
    ripgrep
    p7zip
    jq
    yazi
    imagemagick
    ripdrag
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
