{
  inputs,
  pkgs,
  ...
}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    qimgv
    du-dust
    asciiquarium
    dropbox
    spotify
    obsidian
    vesktop
    obs-studio
    qbittorrent
    materialgram
    inputs.zen-browser.packages."${system}".default
  ];
}
