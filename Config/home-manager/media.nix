{ pkgs, ... }:
let
  myEQ = "lavfi=[volume=volume=-3.2dB,equalizer=f=72:width_type=q:width=1.2:g=1.4,equalizer=f=120:width_type=q:width=2.0:g=0.7,equalizer=f=180:width_type=q:width=1.7:g=-1.6,equalizer=f=360:width_type=q:width=2.0:g=1.3,equalizer=f=490:width_type=q:width=0.7:g=2.8,equalizer=f=510:width_type=q:width=2.0:g=-0.8,equalizer=f=1700:width_type=q:width=2.0:g=-2.1,equalizer=f=7000:width_type=q:width=3.0:g=-2.0]";
in
{
  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs; [ mpvScripts.mpris ];
      config = {
        save-position-on-quit = true;
        af = myEQ;
      };
      bindings = {
        "CTRL+e" = "af toggle @lavfi";
      };
    };
  };
}
