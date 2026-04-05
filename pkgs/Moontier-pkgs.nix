{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mktorrent # <-- File things
    mediainfo
    ffmpeg
    flac
    btop
  ];
}
