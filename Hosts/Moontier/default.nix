{
  config,
  pkgs,
  ...
}:
let
  cfgSops = config.sops.secrets;
in
{
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

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

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
  };

  features.graphicalPkgs.enable = false;

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

    bots = {
      enable = true;
      whatsapp-bot.enable = true;
      discord-bot.enable = true;
    };
  };
}
