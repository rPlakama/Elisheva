{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  networking.hostName = "Moontier";

  environment.systemPackages = with pkgs; [
    btop
    exiftool
    smartmontools
    calibre
    zip
  ];

  # Block device & I/O Queue IOPS Maxxing Rules
  services.udev.extraRules = ''
    # NVMe / SSD (non-rotational): zero-overhead 'none' scheduler, disable entropy overhead, cpu core affinity pinning
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*|sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2", ATTR{queue/nomerges}="0"
    # HDD (rotational): 'bfq' scheduler with expanded request queue (nr_requests=256)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq", ATTR{queue/nr_requests}="256", ATTR{queue/add_random}="0", ATTR{queue/rq_affinity}="2"
  '';

  # High IOPS & Filesystem Cache Memory Tuning
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.vfs_cache_pressure" = 50;
    "fs.file-max" = 2097152;
    "fs.aio-max-nr" = 1048576;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;

  core = {
    user = "rplakama";
    ip = "192.168.0.196";
    domain = "moontier.online";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
    gpu.amd = true;
    cpu.amd = true;
    headless = true;
  };

  features = {
    unifiedDNS = {
      enable = true;
      email = "rPlakama@proton.me";
      gateway = "192.168.0.1";
    };

    library.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    slskd.enable = true;
    homepage.enable = true;
    st.enable = true;
    nextcloud.enable = true;
    jellyfin.enable = true;
    navidrome.enable = true;

    bots = {
      enable = true;
      whatsapp-bot.enable = true;
      discord-bot.enable = true;
    };
  };
}
