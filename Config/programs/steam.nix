{ lib, config, ... }:

{

  config = lib.mkIf (config.networking.hostName == "Centuria") {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
    };
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            gamescope
            mangohud
          ];
      };
    };
  };
}
