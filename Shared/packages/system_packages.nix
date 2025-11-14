{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bat
    fd
    git
    ripgrep
    p7zip
    jq
    yazi
    ripdrag
    cliphist
    wl-clipboard
  ];

  # -- Font's -- #
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
  ];
}
