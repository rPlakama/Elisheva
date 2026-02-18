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
      helix
      dropbox
    ]
    ++ lib.optionals (config.networking.hostName != "Moontier") [
      firefox
      vesktop
      materialgram
      qimgv
      kdePackages.okular
      blender
      yt-dlp
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
      btop-cuda
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      btop-rocm
    ]
    ++ lib.optionals (config.networking.hostName == "Moontier") [
      btop
    ];

}
