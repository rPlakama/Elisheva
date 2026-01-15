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
      firefox
      vesktop
      materialgram
      qimgv
      kdePackages.okular
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
      btop-cuda
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      btop-rocm
    ]
    ++ lib.lists.subtractLists (config.networking.hostName == "Moontier") [
      firefox
      vesktop
      materialgram
      qimgv
      kdePackages.okular
    ];
}
