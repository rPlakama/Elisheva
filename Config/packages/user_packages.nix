{
  pkgs,
  lib,
  isDesktop,
  isElisheva,
  isCenturia,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      dust
      git
    ]
    ++ lib.optionals isDesktop [
      jq
      typst
      nodejs
      lua-language-server
      android-studio

      firefox
      vesktop
      materialgram
      qimgv

      kdePackages.okular
      kdePackages.dolphin

      krita
      jellyfin-desktop
      lorien
    ]
    ++ lib.optionals isCenturia [
      bottles
      blender
      btop-cuda
      lutris
      qbittorrent
    ]
    ++ lib.optionals isElisheva [
      btop-rocm
    ]
    ++ lib.optionals (!isDesktop) [
      btop
    ];

}
