{
  config,
  lib,
  ...
}:

let
  cfg = config.features.scx;
in
{
  options.features.scx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable SCX Configuration";
      default = false;
    };

    scheduler = lib.mkOption {
      type = lib.types.str;
      description = "The SCX scheduler to use (e.g., scx_lavd, scx_rusty, scx_rustland)";
      default = "scx_lavd";
    };

    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Additional command-line flags to pass to the SCX scheduler";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.scx = {
      enable = true;
      scheduler = cfg.scheduler;
      extraArgs = cfg.flags;
    };
  };
}
