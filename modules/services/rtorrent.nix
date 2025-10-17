{ pkgs, ... }:

{

  services.rtorrent = {
    enable = true;
    openFirewall = true;
    package = with pkgs; rtorrent;
  };
}
