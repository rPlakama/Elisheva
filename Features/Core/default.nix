{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.core;
  user = config.core.user;
  gpu = config.core.gpu;
  cpu = config.core.cpu;
  isLaptop = config.core.isLaptop;
in
{
  imports = [ ./gpu.nix ];
  options.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "General Attributes that are default implemented across multiple hosts -- like hardware, services and others.";
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
      ++ lib.optionals (!gpu.nvidia) [ btop-rocm ]
      ++ lib.optionals gpu.nvidia [ btop-cuda ];
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
      tuned = lib.mkIf isLaptop {
        enable = true;
        ppdSupport = true;

        profiles.pwsave = {
          main.include = "powersave";
          video = {
            radeon_powersave = "dpm-battery, auto";
            # IneedColors
          };
        };

        ppdSettings = {
          main = {
            default = "balanced";
            battery_detection = true;
          };
          profiles = {
            power-saver = "pwsave";
            balanced = "balanced";
            performance = "throughput-performance";
          };
          battery.balanced = "balanced-battery";
        };
      };

      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      upower.enable = isLaptop;
      bpftune.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      gvfs.enable = true;
      fwupd.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
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

    boot.kernelParams = lib.mkIf isLaptop (
      if cpu.amd then
        [ "amd_pstate=active" ]
      else if cpu.intel then
        [ "intel_pstate=active" ]
      else
        [ ]
    );

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
