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
    core.user = strOpt "The primary user";
    core.ip = strOpt "IP";

    core.headless = mkEnableOption "Is the host a headless device?";

    core.gpu.amd = mkEnableOption "AMD GPU (RADV/amdgpu)";
    core.gpu.nvidia = mkEnableOption "Nvidia GPU (nvidia/nouveau)";
    core.gpu.intel = mkEnableOption "Intel GPU (i915/Xe)";
    core.cpu.amd = mkEnableOption "AMD CPU (amd_pstate)";
    core.cpu.intel = mkEnableOption "Intel CPU (intel_pstate)";
    core.cpu.micro-arch = mkOption {
      type = nullOr str;
      default = null;
      description = "GCC microarchitecture/cpu to target for this host (e.g. znver5, znver4, alderlake). Null = generic";
    };

    core.isLaptop = mkEnableOption "Whether this host is a laptop (enables battery-aware features)";

    core.git.email = strOpt "git cfg email";
    core.git.user = strOpt "git cfg user";

    core.domain = strOpt "Domain";
    core.zram.enable = mkOption {
      type = bool;
      default = true;
      description = "Enable zram swap (compressed RAM swap)";
    };
    core.zram.algorithm = mkOption {
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
    core.zram.memoryPercent = mkOption {
      type = int;
      default = 150;
      description = "Percentage of RAM to use for zram";
    };
    core.zram.priority = mkOption {
      type = int;
      default = 100;
      description = "Priority of zram swap devices (higher = used first, ensures zram is preferred over disk swap)";
    };
    core.zram.swappiness = mkOption {
      type = int;
      default = 180;
      description = "vm.swappiness value (180 aggressively prefers zram over page cache eviction)";
    };
  };
}
