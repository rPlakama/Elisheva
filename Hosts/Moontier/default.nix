{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./performance.nix
    ../../Features
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    exiftool
  ];

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 2;
    freeSwapThreshold = 10;
    extraArgs = [
      "-M"
      "131072"
    ];
  };

  core = {
    user = "rplakama";
    ip = "192.168.0.160";
    domain = "moontier.online";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
    gpu.intel = {
      enable = true;
      isLegacy = false;
    };
    cpu.intel = true;
    headless = true;
    zram = {
      size = 4048;
      algorithm = "lz4";
    };
  };

  services.journald.settings.Journal = {
    SystemMaxUse = "200M";
    RuntimeMaxUse = "64M";
    Compress = true;
  };

  services.postgresql.settings = {
    shared_buffers = "128MB";
    work_mem = "4MB";
    maintenance_work_mem = "32MB";
    effective_cache_size = "1GB";
    max_connections = 30;
  };

  services.tailscale.useRoutingFeatures = "both";

  features = {
    unifiedDNS = {
      enable = true;
      email = "rPlakama@proton.me";
      gateway = "192.168.0.1";
      tailscaleIP = "100.67.254.80";
    };

    # minecraft-server.enable = true;
    neovim.enable = true;
    library = {
      enable = true;
      # stump.enable = true;
      suwayomi.enable = true;
      kavita.enable = true;
      ao3instance.enable = true;
    };
    galleryDl = {
      enable = true;
      urls = [ "https://weebcentral.com/series/01J76XYH789EJ16X8EC7NB0EVK/Centuria" ];
    };
    rrstack.enable = true;
    searxng.enable = true;
    qbit.enable = true;
    slskd.enable = true;
    homepage.enable = true;
    syncthing.enable = true;
    jellyfin.enable = true;
    # unmanic.enable = true;
    navidrome.enable = true;
    sure = {
      enable = true;
      port = 3001; # Avoid colliding with qui on port 3000
    };
    localrevisor.enable = true;

    bots = {
      enable = true;
      whatsapp-bot.enable = true;
      oxydo-bot.enable = true;
    };
  };
}
