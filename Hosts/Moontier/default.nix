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
    smartmontools
    calibre
    zip
  ];


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
