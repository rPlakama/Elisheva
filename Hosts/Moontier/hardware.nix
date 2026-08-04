{
  config,
  lib,
  modulesPath,
  ...
}:
let
  # BFQ cgroup v2 IO weights (latency-first stack): cap background hogs so
  # Jellyfin / Nextcloud / Navidrome reads win while qBittorrent + arr are busy.
  # Keyed on the unifiedDNS proxyServices inventory (single source of truth);
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
  boot.kernelModules = [ "kvm-amd" ];
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
      "largeio"
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
    # low_latency=1: BFQ privileges interactive/soft real-time streams (Jellyfin/ffmpeg) over background load
    # read_ahead_kb=4096: deep read-ahead for sequential media streaming
    # -- USB-attached variant (active): SkyHawk currently lives in a USB enclosure
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTRS{transport}=="usb", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="512", ATTR{queue/read_ahead_kb}="4096", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0", ATTR{queue/iosched/low_latency}="1"
    # -- Native SATA variant (commented): enable when the drive is moved onto a SATA port
    # ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTRS{transport}=="spi", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="512", ATTR{queue/read_ahead_kb}="4096", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0", ATTR{queue/iosched/low_latency}="1"
  '';

  # High IOPS & Filesystem Cache Memory Tuning
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 3;
    "vm.dirty_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 500;
    "vm.dirty_expire_centisecs" = 1000;
    "vm.dirtytime_expire_seconds" = 43200;
    "vm.vfs_cache_pressure" = 100;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;
  };

  # Derive per-service IO weights from the unifiedDNS service inventory
  # (proxy service names now match systemd unit names 1:1)
  systemd.services = lib.mapAttrs' (
    name: _:
    lib.nameValuePair name {
      serviceConfig.IOWeight = ioWeights.${name};
    }
  ) (lib.filterAttrs (name: _: ioWeights ? ${name}) config.features.unifiedDNS.proxyServices);
}
