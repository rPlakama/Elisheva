{ pkgs, ... }:
{

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapi-intel-hybrid
    ];
  };
}
