{ osConfig, pkgs, ... }:
let
  #targetEq = "lavfi=[volume=volume=-4dB,equalizer=f=1900:width_type=q:w=1.8:g=-2.2,equalizer=f=3100:width_type=q:w=2.0:g=1.0,equalizer=f=6900:width_type=q:w=2.0:g=1.4,equalizer=f=7600:width_type=q:w=1.7:g=-3.0]";
in
{
  programs = {
    mpv = {
      enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
      scripts = with pkgs; [ mpvScripts.mpris ];

      config = {
        save-position-on-quit = true;
        #af = "${targetEq}";
      };

      bindings = {
        #"Ctrl+e" = "no-osd af toggle \"${targetEq}\"; show-text \"EQ Toggled\"";
      };
    };
  };
}
