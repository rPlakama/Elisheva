{ ... }: {
  nixpkgs.overlays = [
    (
      final: prev:
      let
        version = "0.8.3";
        src = prev.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xwayland-satellite";
          tag = "v${version}";
          hash = "sha256-eFEjCCniMCKeWU0PcZNv+tDYe08SLFPjRplyPY8OFt4=";
        };
      in
      {
        xwayland-satellite = prev.xwayland-satellite.overrideAttrs (_: {
          inherit version src;
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            pname = "xwayland-satellite";
            inherit version src;
            hash = "sha256-gMGFvnbxM3hD5fmkSimaFd87GEf6BXFe/MGjoS6VNVU=";
          };
        });
      }
    )
  ];
}
