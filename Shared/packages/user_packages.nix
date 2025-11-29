{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    dust
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
