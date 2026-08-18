{
  config,
  lib,
  modulesPath,
  ...
}:
let
  featureCall = config.features;

  # services without an entry keep the default weight (100).
  ioWeights = {
    qbittorrent = "10";
    qui = "10";
    sonarr = "25";
    radarr = "25";
    lidarr = "25";
    jackett = "25";
    prowlarr = "25";
    slskd = "50";
  };
in
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
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    # device = "/dev/disk/by-uuid/3d02f997-4ef4-4d04-a40a-734742b53660";
    device = "/dev/disk/by-label/nixos";
    fsType = "xfs";
    options = [
      "noatime"
      "lazytime"
      "logbufs=8"
      "logbsize=256k"
      "allocsize=64m"
      "inode64"
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
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Block device & I/O Queue IOPS Maxxing Rules
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", SUBSYSTEMS=="scsi", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="512", ATTR{queue/read_ahead_kb}="8192", ATTR{queue/max_sectors_kb}="4096", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0", ATTR{queue/iosched/low_latency}="1"
  '';

  # High IOPS & Filesystem Cache Memory Tuning
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_writeback_centisecs" = 500;
    "vm.dirty_expire_centisecs" = 1000;
    "vm.dirtytime_expire_seconds" = 43200;
    "vm.vfs_cache_pressure" = 100;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;
  };

  # Derive per-service IO weights from the unifiedDNS service inventory
  systemd.services = lib.mapAttrs' (
    name: _:
    lib.nameValuePair name {
      serviceConfig.IOWeight = ioWeights.${name};
    }
  ) (lib.filterAttrs (name: _: ioWeights ? ${name}) featureCall.unifiedDNS.proxyServices);
}
