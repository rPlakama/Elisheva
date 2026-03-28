{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    intel-media-driver # <-- Intel
    intel-vaapi-driver
    libvdpau-va-gl

    mktorrent # <-- File things
    mediainfo
    ffmpeg
    flac
  ];
}
