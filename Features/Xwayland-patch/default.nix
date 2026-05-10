{ config, lib, ... }:

let
  cfg = config.optionals.features.xwaylandSatellite;
  niriEnabled = config.optionals.features.niri.enable;
  gsrEnabled = config.optionals.features.gpuScreenRecorder.enable;

in
{
  options.optionals.features.xwaylandSatellite.enable = lib.mkOption {
    type = lib.types.bool;
    description = "xwayland-satellite with bczhc's patch applied";
    default = niriEnabled && gsrEnabled;
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        xwayland-satellite =
          let
            patch = prev.fetchpatch {
              url = "https://github.com/bczhc/xwayland-satellite/commit/bac9faf4e1a318c231f0757d9ac0fe0afd08cb2a.patch";
              hash = "sha256-M3x1Xppx1Ziuko+35fIUZ4+nRvNDkTz17PFghjqueTU=";
            };
          in
          prev.xwayland-satellite.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ patch ];
            cargoDeps = prev.rustPlatform.fetchCargoVendor {
              inherit (old) pname version src;
              patches = [ patch ];
              hash = "sha256-Aqiop36x9c8VPoV2nFShRAYn6tks9LnGaI5LfaJA6rk=";
            };
          });
      })
    ];
  };
}
