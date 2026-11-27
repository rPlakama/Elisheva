{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "triforce";
  version = "0.8.4";

  src = fetchurl {
    url = "https://git.triforceproject.com/triforce/downloads/releases/download/v${version}/Triforce-v${version}-x86_64.AppImage";
    hash = "sha256-7//fCYQhcigyU6zFTQam8JaNzoooBnazlWrQdXwhUaU=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      substituteInPlace $out/hookshot-builder.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=triforce' \
        --replace-fail 'Icon=hookshot' 'Icon=triforce'
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraPkgs = pkgs: [ pkgs.webkitgtk_4_1 ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/hookshot-builder.desktop $out/share/applications/triforce.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256/apps/hookshot.png \
      $out/share/icons/hicolor/256x256/apps/triforce.png
  '';

  meta = {
    description = "Native recompilation of Zelda: Ocarina of Time (Switch 2), built from your own game copy, with a Vulkan renderer";
    homepage = "https://triforceproject.com";
    mainProgram = "triforce";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
