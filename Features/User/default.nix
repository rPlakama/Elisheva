{ lib, ... }:
{

  options.core.user = lib.mkOption {
    type = lib.types.str;
    description = "The primary username for the system.";
  };
}
