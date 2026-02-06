{ pkgs, osConfig, ... }:
{
  programs.mpv = {
    enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
    scripts = with pkgs; [ mpvScripts.mpris ];

    config = {
      save-position-on-quit = true;
    };
  };
}
