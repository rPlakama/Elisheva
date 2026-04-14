{ config, lib, ... }:
let
  user = config.core.user;
in
{

  options.core.user = lib.mkOption {
    type = lib.types.str;
    description = "The primary user";
  };
  config = lib.mkIf (user != "") {
    users = {
      groups.${user} = { };
      users.${user} = {
        isNormalUser = true;
        group = user;
        extraGroups = [
          "wheel"
          "video"
          "audio"
        ];
      };
    };
  };
}
