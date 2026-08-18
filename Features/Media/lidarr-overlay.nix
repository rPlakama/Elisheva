{lib, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      lidarr = prev.stdenv.mkDerivation rec {
        pname = "lidarr";
        version = "3.1.3.4987";

        src = prev.fetchurl {
          url = "https://github.com/Lidarr/Lidarr/releases/download/v${version}/Lidarr.develop.${version}.linux-core-x64.tar.gz";
          hash = "sha256-5ScoNmV91YCQIXW3Cwi6Y/onpk1YXE4EbandXFPf5BM=";
        };

        nativeBuildInputs = with prev; [patchelf];
        buildInputs = with prev; [sqlite stdenv.cc.cc.lib icu openssl zlib];

        dontAutoPatchelf = true;
        dontFixup = true;

        installPhase = ''
          mkdir -p $out/bin $out/lib/lidarr
          cp -r . $out/lib/lidarr/

          rpath="${prev.lib.makeLibraryPath [prev.sqlite prev.stdenv.cc.cc.lib prev.icu prev.openssl prev.zlib]}"
          interpreter="$(cat $NIX_CC/nix-support/dynamic-linker)"

          patchelf --set-interpreter "$interpreter" --set-rpath "$rpath" $out/lib/lidarr/Lidarr
          for so in $(find $out/lib/lidarr -name '*.so' -type f); do
            patchelf --set-rpath "$rpath" "$so" 2>/dev/null || true
          done

          ln -s $out/lib/lidarr/Lidarr $out/bin/Lidarr
        '';

        meta =
          prev.lidarr.meta
          // {
            version = version;
            changelog = "https://github.com/Lidarr/Lidarr/releases/tag/v${version}";
          };
      };
    })
  ];
}
