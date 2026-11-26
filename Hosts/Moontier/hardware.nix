{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cpu = config.core.cpu;

  dotnetWorkstationEnv = {
    DOTNET_GCServer = "0";
    DOTNET_EnableDiagnostics = "0";
    COMPlus_GCServer = "0";
    COMPlus_EnableDiagnostics = "0";
  };

  dotnetServices = [
    "jellyfin"
    "kavita"
    "slskd"
    "sonarr"
    "radarr"
    "prowlarr"
    "jackett"
  ];

  serviceTiers = {
    # Critical / latency-sensitive networking & DNS
    adguardhome = {
      CPUWeight = 200;
      Nice = -5;
      IOWeight = 200;
      MemoryHigh = "384M";
      MemoryMax = "512M";
    };
    nginx = {
      CPUWeight = 200;
      Nice = -5;
      IOWeight = 200;
    };
    tailscaled = {
      CPUWeight = 200;
      Nice = -5;
      IOWeight = 200;
    };

    # User-facing media & web services
    jellyfin = {
      CPUWeight = 100;
      IOWeight = 100;
      MemoryHigh = "1536M";
      MemoryMax = "2G";
    };
    kavita = {
      CPUWeight = 100;
      IOWeight = 100;
      MemoryHigh = "768M";
      MemoryMax = "1G";
    };
    navidrome = {
      CPUWeight = 100;
      IOWeight = 100;
    };
    ao3instance = {
      CPUWeight = 100;
      IOWeight = 100;
    };
    sure-web = {
      CPUWeight = 100;
      IOWeight = 100;
    };

    # Background / batch services
    qbittorrent = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 10;
      IOSchedulingClass = "idle";
      MemoryHigh = "768M";
      MemoryMax = "1G";
    };
    qui = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 10;
    };
    sonarr = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 25;
    };
    radarr = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 25;
    };
    jackett = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 25;
    };
    prowlarr = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 25;
    };
    slskd = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 50;
    };
    sure-worker = {
      CPUWeight = 40;
      Nice = 10;
      IOWeight = 25;
    };
    podman-suwayomi-server = {
      CPUWeight = 50;
      Nice = 5;
      IOWeight = 50;
      MemoryHigh = "1G";
      MemoryMax = "1536M";
    };

    # Heavy CPU/IO background workers
    syncthing = {
      CPUWeight = 20;
      Nice = 15;
      IOWeight = 10;
      IOSchedulingClass = "idle";
      CPUQuota = "150%";
      MemoryHigh = "512M";
      MemoryMax = "768M";
    };
    flaresolverr = {
      CPUWeight = 20;
      Nice = 15;
      IOWeight = 10;
      CPUQuota = "150%";
      MemoryHigh = "768M";
      MemoryMax = "1G";
    };
    gallery-dl = {
      CPUWeight = 20;
      Nice = 15;
      IOWeight = 10;
      IOSchedulingClass = "idle";
    };
  };

in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "uas"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = if cpu.intel then [ "kvm-intel" ] else [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "xfs";
    options = [
      "noatime"
      "lazytime"
      "logbufs=8"
      "logbsize=256k"
      "inode64"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Block device & I/O Queue Tuning for mixed random + sequential HDD workloads
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", SUBSYSTEMS=="scsi", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="128", ATTR{queue/read_ahead_kb}="1024", ATTR{queue/max_sectors_kb}="4096", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0", ATTR{queue/iosched/low_latency}="1"
  '';

  # VM & I/O tuning (avoid multi-GB dirty page stalls on 7.66 GiB RAM + HDD)
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;

    "vm.dirty_background_bytes" = 0;
    "vm.dirty_bytes" = 0;
    "vm.dirty_writeback_centisecs" = 500; # 5s
    "vm.dirty_expire_centisecs" = 1500; # 15s

    "vm.vfs_cache_pressure" = 50;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;
  };

  systemd.services = lib.mkMerge [
    (lib.mapAttrs (
      _: tierCfg: {
        serviceConfig = tierCfg;
      }
    ) serviceTiers)
    (lib.genAttrs dotnetServices (_: {
      environment = dotnetWorkstationEnv;
    }))
    {
      syncthing.environment = {
        GOMAXPROCS = "2";
        GOMEMLIMIT = "384MiB";
      };
    }
  ];
}
