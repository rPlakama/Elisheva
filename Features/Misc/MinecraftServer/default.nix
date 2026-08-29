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
  modpack = pkgs.fetchPackwizModpack {
    url = "file://${./moontier-modpack/pack.toml}";
    packHash = lib.fakeHash;
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

      servers.moontier = {
        enable = true;
        # package = pkgs.paperServers.paper-26_2;
        package = pkgs.fabricServers.fabric-26_2;
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
          motd = "Moontier Minecraft Server";
          white-list = false;
          enable-rcon = true;
          "rcon.password" = "moontier";
        };
        jvmOpts = "-Xms2G -Xmx2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Dcom.mojang.eula.agree=true -XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
      };
    };
  };
}
