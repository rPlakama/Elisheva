{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf optionals;
  cfg = config.features.core;
  gpu = config.core.gpu;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        ripgrep
        cifs-utils
        zip
        yazi
        wget
        age
        sops
        fzf
        git
        unzip
        p7zip-rar
        unrar
        dust
        jq
        fd
        man-pages-posix
        man-pages
        inputs.twatch.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ optionals (!gpu.nvidia) [ btop-rocm ]
      ++ optionals gpu.nvidia [ btop-cuda ];
  };
}
