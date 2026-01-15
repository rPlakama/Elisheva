{ ... }:
{
  fileSystems."/mnt/secondary" = {
    device = "/dev/disk/by-uuid/19b0323b-cdf8-4b74-acfb-08a0a6344902";
    fsType = "ext4";
    options = [ "defaults" ];
  };
}
