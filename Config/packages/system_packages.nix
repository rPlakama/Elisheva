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
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      ryzenadj
    ];
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    montserrat
    arkpandora_ttf
  ];
}
