{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bat
    fd
    ripgrep
    p7zip
    yazi
    ripdrag
    mate.mate-polkit
    cliphist
    wl-clip-persist
    wl-clipboard
    git
    pavucontrol
  ];

  # -- Font's -- #
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];
}
