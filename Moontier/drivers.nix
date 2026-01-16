{ pkgs, ... }:
{
  fileSystems."/mnt/secondary" = {
    device = "/dev/disk/by-uuid/19b0323b-cdf8-4b74-acfb-08a0a6344902";
    fsType = "ext4";
    options = [ "defaults" ];
  };


  environment.systemPackages = [ pkgs.mergerfs ];
  fileSystems."/mnt/pool" = {
    fsType = "fuse.mergerfs";
    device = "/var/lib/local-storage:/mnt/secondary";

    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "category.create=mfs"
      "minfreespace=20G"
      "fsname=mergerfs"
    ];
  };
}
