{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let

  featureCall = config.features;

  #nix shell nixpkgs#packwiz
  baselineModsDir = ./baseline-mods;
  additionalsDir = ./additionals;

  baselineMods = pkgs.fetchPackwizModpack {
    url = "file://${baselineModsDir}/pack.toml";
    packHash = "sha256-bgriUdW+8qKdHqh820WEdEnMgQzLmvVEh5+0y7CytHA=";
  };

  additionals = pkgs.fetchPackwizModpack {
    url = "file://${additionalsDir}/pack.toml";
    packHash = "sha256-w/kLu/5KqZVjxii0iX6IYM4Qr00NhaSt8K5PNZgRhtE=";
  };

  modpack = pkgs.symlinkJoin {
    name = "moontier-modpack";
    paths = [
      baselineMods
      additionals
    ];
  };

in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.features.minecraft-server.enable = lib.mkEnableOption "Minecraft server";

  config = lib.mkIf featureCall.minecraft-server.enable {
    nixpkgs.overlays = lib.mkBefore [ inputs.nix-minecraft.overlay ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 43000 ];

    environment.systemPackages = with pkgs; [
      tmux
    ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      # dataDir = "/srv/minecraft";

      servers.ratomorto = {
        enable = true;
        # package = pkgs.paperServers.paper-26_2;
        # fabric requires java 25 for fabric-26_2
        package = pkgs.fabricServers.fabric-26_2.override {
          jre_headless = pkgs.openjdk25_headless;
        };
        openFirewall = true;

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        serverProperties = {
          server-port = 43000;
          difficulty = 3;
          online-mode = false;
          gamemode = 0;
          max-players = 5;
          view-distance = 8;
          simulation-distance = 6;
          motd = "MT-Server";
          white-list = false;
          enable-rcon = true;
          "rcon.password" = "moontier";
        };
        jvmOpts = "-Xms3G -Xmx3G -XX:+UseZGC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -Dcom.mojang.eula.agree=true";
      };
    };
  };
}
