{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      bat
      age
      sops
      fd
      ripgrep
      p7zip
      yazi
      ripdrag
      nvd
      nh
      nix-output-monitor
      xwayland-satellite
      papirus-folders
      papirus-icon-theme

    ]
    ++ lib.optionals (config.networking.hostName != "Moontier") [
      android-tools
      volantes-cursors
      ripdrag
      distrobox
    ]
    ++ lib.optionals (config.networking.hostName == "Moontier") [
      beets
      ffmpeg-full
    ];
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
