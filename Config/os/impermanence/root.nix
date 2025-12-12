{ ... }:

{
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=25%"
      "mode=755"
    ];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "xfs";
    neededForBoot = true;
  };
}
