{
  lib,
  isDesktop,
  isMoontier,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      bat
      fd
      ripgrep
      p7zip
      yazi

    ]
    ++ lib.optionals isDesktop [
      android-tools
      volantes-cursors
      age
      sops
      xwayland-satellite
      ripdrag
      distrobox
      papirus-folders
      papirus-icon-theme

    ]
    ++ lib.optionals isMoontier [
      beets
      ffmpeg-full
    ];
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
