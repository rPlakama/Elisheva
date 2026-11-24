{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "fritchii";
  version = "6.5";

  src = fetchurl {
    url = "https://github.com/Frizti/Fritchii/releases/download/fritchii-v${version}/Fritchii-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-gEtnm3IMgrtc7ixfaKxZxfvo/8fxavN3a6HEoV0NJD0=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  udevRules = fetchurl {
    url = "https://raw.githubusercontent.com/Frizti/Fritchii/fritchii-v${version}/dist/72-eden-input.rules";
    hash = "sha256-x1zDXiEmN9hedVird///wKVReG+iRofCK7k1E1TggNE=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/usr/share/applications/io.github.frizti.fritchii.desktop \
      $out/share/applications/io.github.frizti.fritchii.desktop
    substituteInPlace $out/share/applications/io.github.frizti.fritchii.desktop \
      --replace-fail "Exec=lichii %f" "Exec=fritchii %f" \
      --replace-fail "TryExec=lichii" "TryExec=fritchii"

    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/fritchii.png \
      $out/share/icons/hicolor/512x512/apps/fritchii.png

    install -Dm444 ${udevRules} $out/lib/udev/rules.d/72-eden-input.rules
  '';

  meta = {
    description = "Fritchii, a Lichii fork tuned for Frontier (Nintendo Switch/Switch 2 emulator)";
    homepage = "https://github.com/Frizti/Fritchii";
    mainProgram = "fritchii";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
