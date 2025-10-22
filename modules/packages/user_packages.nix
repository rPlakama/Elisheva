{
  inputs,
  pkgs,
  ...
}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    qimgv
    du-dust
    dropbox
    spotify
    obsidian
    obs-studio
    qbittorrent
    materialgram
    inputs.zen-browser.packages."${system}".default
  ];
}
