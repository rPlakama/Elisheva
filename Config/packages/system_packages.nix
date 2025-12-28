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
      cliphist
      wl-clipboard
      wl-mirror

      # Extras
      volantes-cursors
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
