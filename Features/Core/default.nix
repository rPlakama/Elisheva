{ lib, ... }: {
  imports = lib.mapAttrsToList (name: _: ./${name}) (
    lib.filterAttrs (
      name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
    ) (builtins.readDir ./.)
  );

  options.core = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "The primary user";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "IP";
      default = "";
    };
    headless = lib.mkEnableOption "Is the host a headless device?";
    gpu = {
      amd = lib.mkEnableOption "AMD GPU (RADV/amdgpu)";
      nvidia = lib.mkEnableOption "Nvidia GPU (nvidia/nouveau)";
      intel = lib.mkEnableOption "Intel GPU (i915/Xe)";
    };
    cpu = {
      amd = lib.mkEnableOption "AMD CPU (amd_pstate)";
      intel = lib.mkEnableOption "Intel CPU (intel_pstate)";
    };
    isLaptop = lib.mkEnableOption "Whether this host is a laptop (enables battery-aware features)";
    git = {
      email = lib.mkOption {
        type = lib.types.str;
        description = "git cfg email";
        default = "";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "git cfg user";
        default = "";
      };
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Domain";
      default = "";
    };
    zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable zram swap (compressed RAM swap)";
      };
      algorithm = lib.mkOption {
        type = lib.types.enum [ "lzo" "lzo-rle" "lz4" "lz4hc" "zstd" "deflate" "842" ];
        default = "zstd";
        description = "Compression algorithm for zram";
      };
      memoryPercent = lib.mkOption {
        type = lib.types.int;
        default = 150;
        description = "Percentage of RAM to use for zram";
      };
      priority = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Priority of zram swap devices (higher = used first, ensures zram is preferred over disk swap)";
      };
      swappiness = lib.mkOption {
        type = lib.types.int;
        default = 180;
        description = "vm.swappiness value (180 aggressively prefers zram over page cache eviction)";
      };
    };
  };

  options.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "General Attributes that are default implemented across multiple hosts -- like hardware, services and others.";
  };
}
