{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      lidarr = prev.stdenv.mkDerivation rec {
        pname = "lidarr";
        version = "3.1.3.4987";

        src = prev.fetchurl {
          url = "https://github.com/Lidarr/Lidarr/releases/download/v${version}/Lidarr.develop.${version}.linux-core-x64.tar.gz";
          hash = "sha256-5ScoNmV91YCQIXW3Cwi6Y/onpk1YXE4EbandXFPf5BM=";
        };

        nativeBuildInputs = [ prev.autoPatchelfHook ];
        buildInputs = with prev; [ sqlite stdenv.cc.cc.lib icu openssl zlib ];

        autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

        installPhase = ''
          mkdir -p $out/bin $out/lib/lidarr
          cp -r . $out/lib/lidarr/
          ln -s $out/lib/lidarr/Lidarr $out/bin/Lidarr
        '';

        meta = prev.lidarr.meta // {
          version = version;
          changelog = "https://github.com/Lidarr/Lidarr/releases/tag/v${version}";
        };
      };
    })
  ];
}
