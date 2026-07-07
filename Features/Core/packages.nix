{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.core;
  gpu = config.core.gpu;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        ripgrep
        cifs-utils
        zip
        neovim
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
      ++ lib.optionals (!gpu.nvidia) [ btop-rocm ]
      ++ lib.optionals gpu.nvidia [ btop-cuda ];
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];
  };
}
