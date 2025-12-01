{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bat
    fd
    git
    ripgrep
    p7zip
    yazi
    ripdrag
    cliphist
    wl-clipboard
    wl-mirror
  ];

  # -- Font's -- #
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
