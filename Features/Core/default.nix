{
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    filterAttrs
    hasSuffix
    ;
  inherit (types)
    str
    bool
    int
    enum
    nullOr
    ;

  strOpt =
    desc:
    mkOption {
      type = str;
      description = desc;
      default = "";
    };

  importFiles = builtins.attrNames (
    filterAttrs (n: t: t == "regular" && hasSuffix ".nix" n && n != "default.nix") (
      builtins.readDir ./.
    )
  );
in
{
  imports = map (n: ./${n}) importFiles;

  options = {
    core = {
      # Generic
      user = strOpt "The primary user";
      ip = strOpt "IP";
      headless = mkEnableOption "Is the host a headless device?";
      isLaptop = mkEnableOption "Whether this host is a laptop (enables battery-aware features)";

      # gpu
      gpu = {
        amd = mkEnableOption "AMD GPU (RADV/amdgpu)";
        nvidia = mkEnableOption "Nvidia GPU (nvidia/nouveau)";
        intel = mkEnableOption "Intel GPU (i915/Xe)";

      };
      # Cpu
      cpu = {
        amd = mkEnableOption "AMD CPU (amd_pstate)";
        intel = mkEnableOption "Intel CPU (intel_pstate)";
      };

      # Git
      git.email = strOpt "git cfg email";
      git.user = strOpt "git cfg user";

      domain = strOpt "Domain";
      # Zram
      zram = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Enable zram swap (compressed RAM swap)";
        };
        algorithm = mkOption {
          type = enum [
            "lzo"
            "lzo-rle"
            "lz4"
            "lz4hc"
            "zstd"
            "deflate"
            "842"
          ];
          default = "zstd";
          description = "Compression algorithm for zram";
        };

        memoryPercent = mkOption {
          type = int;
          default = 150;
          description = "Percentage of RAM to use for zram";
        };
        priority = mkOption {
          type = int;
          default = 100;
          description = "Priority of zram swap devices (higher = used first, ensures zram is preferred over disk swap)";
        };
        swappiness = mkOption {
          type = int;
          default = 180;
          description = "vm.swappiness value (180 aggressively prefers zram over page cache eviction)";
        };
      };
    };
  };
}
