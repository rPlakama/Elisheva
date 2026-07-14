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
  };

  options.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "General Attributes that are default implemented across multiple hosts -- like hardware, services and others.";
  };
}
