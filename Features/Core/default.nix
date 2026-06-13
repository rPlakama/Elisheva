{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.core;
  user = config.core.user;
  isNvidia = config.features.nvidia.enable;
in

{
  options.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Essential system segments for my Hosts";
  };
  config = lib.mkIf cfg.enable {
    security.sudo-rs.enable = true;
    environment.systemPackages =
      with pkgs;
      [
        ripgrep
        cifs-utils

        p7zip
        zip
        ripgrep
        neovim
        yazi
        wget
        age
        sops
        fzf
        git
        unzip
        dust
        jq
        fd

        man-pages-posix
        man-pages

      ]

      ++ lib.optionals (!isNvidia) [

        btop-rocm

      ]

      ++ lib.optionals isNvidia [

        btop-cuda

      ];

    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];
    networking.networkmanager.enable = true;
    programs = {
      fish = {
        enable = true;
        generateCompletions = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    services = {

      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      upower.enable = true;
      bpftune.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      gvfs.enable = true;
      fwupd.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      tailscale = {
        enable = true;
        openFirewall = true;
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };

    features.preservation.system.directories = [
      "/var/lib/fwupd"
    ];

    documentation = {
      dev.enable = true;
      man.enable = true;
    };

    hardware = {
      enableAllFirmware = true;
      enableRedistributableFirmware = true;
    };

    hjem.users.${user} = {
      enable = true;

      xdg.config.files = {
        "fish/config.fish".source = ./config.fish;
        "yazi/yazi.toml".source = ./yazi.toml;
        "yazi/keymap.toml".source = ./keymap.toml;
      };
    };

  };
}
