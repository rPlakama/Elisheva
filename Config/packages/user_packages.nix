{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      dust
      dropbox
      firefox
      spotify
      vesktop
      microfetch
      materialgram
      qimgv
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      onlyoffice-desktopeditors
    ];
}
