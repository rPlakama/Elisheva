{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let

  featureCall = config.features;

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
          mods = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              fabric-api = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/NqwNSxwA/fabric-api-0.158.0%2B26.2.jar";
                sha512 = "4c2c1ebe74ffd54875a01ff371b53ba3d8674ac98d561f7dae02a96d3d37fbdbc5f5abc6e820f73b6154d6f873ddd05a442b0998ed2d456863dc0ad972e040a6";
              };
              no-chat-reports = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/aDbxaVTi/NoChatReports-FABRIC-26.2-v2.20.2.jar";
                sha512 = "aa14fa2d1cc94803f4c965fd817a945823037237bd7a1fea9dc9a0c6427084d25b8d9273da76bc132fe68794d2be8b91540bfff1309125aea37820c12bff0268";
              };
              krypton = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/5WeL0Nkz/krypton-0.3.1.jar";
                sha512 = "b8d9af34cd0050493afb8a6232cb8f785daa9d8887b7045f6e6a53c6bb9b5ffc4318fd9b0347a940eacfeba4773f10cb80ae0be1e79ce4c1888f96eda21e564e";
              };
              clumps = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/dEMopoOJ/Clumps-fabric-26.2-26.2.1.jar";
                sha512 = "a57044f0c9a07b19cd38b85528fd6b3958600c3ed1568d8a7ce32a7a473570362861ef433be4f23b02a43c05d658e9a5a71f9218fbdb963ae76a1714a0439fbe";
              };
              c2me = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/VSNURh3q/versions/jSMMstCy/c2me-fabric-mc26.2-0.4.2-alpha.0.43.jar";
                sha512 = "c9c9c9babe4d94e06abf72c92e453aaa39c82634a7ae646d1041f673e12eff3d99e77e205a686ea53d0a5ae143e9e1e6ed595b3ccfcaeafe64cbfb6327e2f375";
              };
              debugify = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/V2I3yC58/debugify-26.2.0.0.jar";
                sha512 = "41999eeff94c6a69810d65571bb09cb49a6c29a1e134f49fe31fe826e41f7a6cf7997350fb0d175270fe10c81e5e6433738562f8a22a57725a6f76544414e396";
              };
              distant-horizons = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/uCdwusMi/versions/gBf0SaV1/DistantHorizons-3.2.0-b-26.2-fabric-neoforge.jar";
                sha512 = "c1b8857776a002c2232887d891bd49195f3c3127a7abe1242376ad20371e31554d8ba6c7c92a195b70782cad94fe970941487f2af530988d9b8819455c859e72";
              };
              balm = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/hT8Zt2uD/balm-fabric-26.2-26.2.0.6.jar";
                sha512 = "0a0b4b71f2877abd234cf85302165bb05b2cb0e3c0b7c543fa0c12e5ae271dc879f300ecb6f1dbb00c6a8bf5e42e454d4f168a970a0f4a64c4a82122bf2a8fc6";
              };
              netherportalfix = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/nPZr02ET/versions/GQpccFqg/netherportalfix-fabric-26.2-26.2.0.1.jar";
                sha512 = "59d02006e5f51bd9a7e57de05a39f6803e504303bc22fb3451e41756c41ff7333ff6348ee51cf3b585dcf27454c0556407523a1a0bc4a84639e0d0b331ce8b6b";
              };
              almanac = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/Gi02250Z/versions/meYgadd9/almanac-fabric-26.2-1.26.7.3.jar";
                sha512 = "ef236e3edefa30cb6dddcf0da64bbfcd7d9b8e64c868343d0aaa325665fc64015d447d7d980f1e910416e8ad3f54797285619c0c45ec1a86120cf67ffcfe7af0";
              };
              let-me-despawn = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/B2nrDb9C/letmedespawn-fabric-26.2-1.26.7.3.jar";
                sha512 = "51a489c30f0f38165150a7cf5e1cbbdc5288e7865834e96cb53f0327cafe96da53e6fae95d8bd3ea034e1e56faa15dc10a9a207cbef3accdb99cc50780fec855";
              };
              lithostitched = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/XaDC71GB/versions/V3XWhM8r/lithostitched-1.8.0%2Bbeta3-fabric-26.2.jar";
                sha512 = "32f9b747b80c9b5ac01ee98e167491d4ea433158c22462f80e301fb32238c1e01f5c55dded2fb20e0745720de7f3881971f21dfef03c135c1fed5a8afb2ea8a3";
              };
              terralith = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/OxfI2n80/Terralith_26.2_v2.6.4.jar";
                sha512 = "0830f4601674c4ea58d247a71bfdc820e4676900e173c7d6df4e58e348a09da43b279cea060df7b67e6f74c84e2a05b401b2df79836c37cffc8dc994844ab250";
              };

              # --- Performance additions ---
              lithium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/UPNexAfy/lithium-fabric-0.25.2%2Bmc26.2.jar";
                sha512 = lib.fakeHash;
              };
              ferritecore = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
                sha512 = lib.fakeHash;
              };
              noisium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/PVSNTgcU/versions/noisium-fabric-2.8.5+mc26.2.jar";
                sha512 = lib.fakeHash;
              };
            }
          );
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
