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

  environment.systemPackages = with pkgs; [
    smartmontools
    calibre
    exiftool
  ];

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 2;
    freeSwapThreshold = 10;
  };

  services.glances.enable = true;

  core = {
    user = "rplakama";
    ip = "192.168.0.160";
    domain = "moontier.online";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
    gpu.intel = true;
    cpu.intel = true;
    headless = true;
    zram.size = 4048;
  };

  services.tailscale.useRoutingFeatures = "both";

  features = {
    unifiedDNS = {
      enable = true;
      email = "rPlakama@proton.me";
      gateway = "192.168.0.1";
      tailscaleIP = "100.67.254.80";
      proxyServices.glances = {
        port = 61208;
        icon = "sh-glances";
        description = "System monitoring";
      };
    };

    neovim.enable = true;
    library.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    slskd.enable = true;
    homepage.enable = true;
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
