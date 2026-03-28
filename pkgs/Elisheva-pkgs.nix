{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    android-studio
    btop-rocm
  ];
}
