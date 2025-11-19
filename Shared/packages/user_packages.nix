{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    dust
    qimgv
    dropbox
    firefox
    spotify
    obsidian
    vesktop
    microfetch
    qbittorrent
    materialgram
  ];
}
