{
  pkgs,
  lib,
  config,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      dust
      dropbox
    ]
    ++ lib.optionals (config.networking.hostName != "Moontier") [
      firefox
      vesktop
      materialgram
      qimgv
      kdePackages.okular
      kdePackages.dolphin
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
      blender
      btop-cuda
      lutris
      qbittorrent
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      btop-rocm
    ]
    ++ lib.optionals (config.networking.hostName == "Moontier") [
      btop
    ];

}
