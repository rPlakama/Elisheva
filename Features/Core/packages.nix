{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) optionals;
  gpu = config.core.gpu;
  user = config.core.user;
in
{
  environment.systemPackages = with pkgs; [
    cifs-utils
    man-pages-posix
    man-pages
  ];

  hjem.users.${user} = {
    packages =
      with pkgs;
      [
        ripgrep
        zip
        yazi
        wget
        age
        sops
        fzf
        fishPlugins.fzf-fish
        git
        unzip
        p7zip-rar
        unrar
        dust
        jq
        fd
        inputs.twatch.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ optionals (!gpu.nvidia) [ btop-rocm ]
      ++ optionals gpu.nvidia [ btop-cuda ];
  };
}
