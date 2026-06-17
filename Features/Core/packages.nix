{
  config,
  lib,
  pkgs,
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
        p7zip
        zip
        neovim
        yazi
        wget
        age
        sops
        fzf
        git
        unzip
        dust
        jq
        fd
        man-pages-posix
        man-pages
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
