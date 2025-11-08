{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    dust
    glow
    krita
    qimgv
    dropbox
    firefox
    spotify
    obsidian
    vesktop
    microfetch
    obs-studio
    qbittorrent
    materialgram
  ];
}
