{
  lib,
  ...
}:

let
  contents = builtins.readDir ./.;
  nixFiles = lib.filterAttrs (name: type:
    type == "regular"
    && lib.hasSuffix ".nix" name
    && name != "default.nix"
  ) contents;
  modulePaths = lib.mapAttrsToList (name: _: ./${name}) nixFiles;
in
{
  imports = modulePaths;

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
    gpu = {
      amd = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "AMD GPU (RADV/amdgpu)";
      };
      nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Nvidia GPU (nvidia/nouveau)";
      };
      intel = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Intel GPU (i915/Xe)";
      };
    };
    cpu = {
      amd = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "AMD CPU (amd_pstate)";
      };
      intel = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Intel CPU (intel_pstate)";
      };
    };
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this host is a laptop (enables battery-aware features)";
    };
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
