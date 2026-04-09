{ pkgs, ... }:
{

  fileSystems."/" = {
    options = [
      "defaults"
      "noatime"
      "logbsize=256k"
      "allocsize=64m"
    ];

  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };
}
