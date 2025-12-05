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
      kdePackages.okular
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
    ];
}
