{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    dust
    dropbox
    firefox
    spotify
    vesktop
    microfetch
    materialgram
  ];
}
