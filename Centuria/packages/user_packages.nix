{
  inputs,
  pkgs,
  ...
}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    dust
    glow
    krita
    qimgv
    dropbox
    spotify
    obsidian
    vesktop
    microfetch
    obs-studio
    qbittorrent
    materialgram
    bottles
    icu
    libxcrypt-legacy
    glib
    inputs.zen-browser.packages."${system}".default
  ];
}
