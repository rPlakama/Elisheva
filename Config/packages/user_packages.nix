{
  pkgs,
  lib,
  config,
  inputs,
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
      inputs.affinity-nix.packages.${pkgs.system}.v3

    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      btop-rocm
    ]
    ++ lib.optionals (config.networking.hostName == "Moontier") [
      btop
    ];

}
