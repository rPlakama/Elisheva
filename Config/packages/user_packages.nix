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
      discord-canary
      materialgram
      qimgv
      fresh-editor
      kdePackages.okular
    ]
    ++ lib.optionals (config.networking.hostName == "Centuria") [
      bottles
      btop-cuda
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      btop-rocm
    ];
}
