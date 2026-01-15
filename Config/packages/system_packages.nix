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
      fd
      ripgrep
      p7zip
      yazi
      ripdrag
      android-tools

      xwayland-satellite
      volantes-cursors
      papirus-folders
      papirus-icon-theme

    ]

    ++ lib.lists.subtractLists (config.networking.hostName == "Moontier") [
      android-tools
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      mesa
    ];
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
