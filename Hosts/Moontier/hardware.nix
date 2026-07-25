{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "uas"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    # device = "/dev/disk/by-uuid/3d02f997-4ef4-4d04-a40a-734742b53660";
    device = "/dev/disk/by-label/nixos";
    fsType = "xfs";
    options = [
      "noatime"
      "lazytime"
      "logbufs=4"
      "logbsize=256k"
      "allocsize=64m"
      "inode64"
      "largeio"
      "attr2"
    ];
  };

  fileSystems."/boot" = {
    # device = "/dev/disk/by-uuid/6B54-471D";
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Block device & I/O Queue IOPS Maxxing Rules
  services.udev.extraRules = ''
    # NVMe / SSD (non-rotational): zero-overhead 'none' scheduler, disable entropy overhead, cpu core affinity pinning
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*|sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0"
    # HDD (rotational): 'bfq' scheduler tuned for Skyhawk AI 256MB cache surveillance drive
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="512", ATTR{queue/read_ahead_kb}="1024", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0", ATTR{queue/iosched/low_latency}="0"
  '';

  # High IOPS & Filesystem Cache Memory Tuning
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 3;
    "vm.dirty_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 500;
    "vm.dirty_expire_centisecs" = 1000;
    "vm.vfs_cache_pressure" = 100;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;
  };
}
