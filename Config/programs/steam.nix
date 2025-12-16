{ lib, config, ... }:

{

  config = lib.mkIf (config.networking.hostName == "Centuria") {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam.enable = true;
    };
  };
}
