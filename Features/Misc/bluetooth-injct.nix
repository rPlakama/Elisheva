{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.bluetooth-injct;
in
{
  options.features.bluetooth-injct = {
    enable = lib.mkEnableOption "Bluetooth device delay opt";

    deviceMac = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "AA:BB:CC:DD:EE:FF";
      description = "Optional Bluetooth MAC address (e.g., FiiO BTR11) to strip SNIFF/RSWITCH link policies on connection.";
    };

    boostXhciIrq = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable threaded IRQs and boost xhci_hcd USB host controller threads to SCHED_FIFO 60.";
    };

    disableWifi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Soft-block Wi-Fi via rfkill and disable wireless scanning so the M.2 combo radio dedicates 100% of its antenna/PTA slots to Bluetooth.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Kernel boot parameters: prevent btusb micro-suspends & enable preemptible IRQ threads
    boot.kernelParams = [
      "btusb.enable_autosuspend=0"
    ]
    ++ lib.optional cfg.boostXhciIrq "threadirqs";

    # 2. Clamp default L2CAP socket write buffer to prevent kernel-space packet queuing
    boot.kernel.sysctl = {
      "net.core.wmem_default" = lib.mkDefault 32768;
    };

    # 3. Optional Wi-Fi RF kill & scan suppression to eliminate 2.4 GHz PTA antenna time-slicing
    networking.wireless.enable = lib.mkIf cfg.disableWifi (lib.mkForce false);
    networking.networkmanager.wifi.powersave = lib.mkIf (!cfg.disableWifi) false;

    systemd.services.bt-wifi-rfkill = lib.mkIf cfg.disableWifi {
      description = "Soft-block Wi-Fi radio to eliminate M.2 combo card PTA contention with Bluetooth";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-pre.target"
        "NetworkManager.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "bt-wifi-rfkill" ''
          ${pkgs.util-linux}/bin/rfkill block wifi || true
          if command -v ${pkgs.networkmanager}/bin/nmcli >/dev/null 2>&1; then
            ${pkgs.networkmanager}/bin/nmcli radio wifi off || true
          fi
        '';
        ExecStop = pkgs.writeShellScript "bt-wifi-unblock" ''
          ${pkgs.util-linux}/bin/rfkill unblock wifi || true
          if command -v ${pkgs.networkmanager}/bin/nmcli >/dev/null 2>&1; then
            ${pkgs.networkmanager}/bin/nmcli radio wifi on || true
          fi
        '';
      };
    };

    # 4. BlueZ controller & link-layer policy hardening
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          ControllerMode = "bredr"; # Change to "dual" if you use BLE peripherals (mice/keyboards)
          FastConnectable = true;
          JustWorksRepairing = "always";
          TemporaryTimeout = 10;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # 5. Systemd hooks: strip SNIFF/RSWITCH link policy, stop background page scans, & prioritize xHCI IRQs
    systemd.services.bluetooth.serviceConfig.ExecStartPost = [
      "-${pkgs.bluez}/bin/hciconfig hci0 lp NONE"
    ]
    ++ lib.optionals (cfg.deviceMac != null) [
      "-${pkgs.bluez}/bin/hcitool lp ${cfg.deviceMac} NONE"
      "-${pkgs.bluez}/bin/hciconfig hci0 noscan"
    ];

    systemd.services.bt-xhci-rt-prio = lib.mkIf cfg.boostXhciIrq {
      description = "Pin xHCI USB host controller IRQ threads to SCHED_FIFO 60 for low-latency Bluetooth";
      wantedBy = [ "multi-user.target" ];
      after = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "boost-xhci-irq" ''
          for pid in $(${pkgs.procps}/bin/pgrep -f "irq/.*xhci_hcd"); do
            ${pkgs.util-linux}/bin/chrt -f -p 60 "$pid" || true
          done
        '';
      };
    };

    # 6. Udev rules: lock USB runtime power control to 'on' for btusb & apply lp NONE on connect
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", TEST=="power/control", ATTR{power/control}="on"
    ''
    + lib.optionalString (cfg.deviceMac != null) ''
      ACTION=="add", SUBSYSTEM=="bluetooth", RUN+="${pkgs.bluez}/bin/hcitool lp ${cfg.deviceMac} NONE", RUN+="${pkgs.bluez}/bin/hciconfig hci0 noscan"
    '';

    # 7. PipeWire & WirePlumber configuration
    services.pipewire = {
      extraConfig.pipewire."92-sample-rates" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          # Locked to 48000: LDAC only supports 48k/96k, avoiding graph clock switches on 44.1k tracks
          "default.clock.allowed-rates" = [ 48000 ];
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 1024;
        };
      };

      wireplumber.extraConfig."51-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.default.rate" = 48000;
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [
            "ldac"
            "aac"
            "sbc"
          ];
        };

        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props = {
              "bluez5.a2dp.ldac.quality" = "mq"; # 330 kbps
              "bluez5.auto-connect" = [ "a2dp_sink" ];
            };
          }
          {
            matches = [ { "node.name" = "~bluez_output.*"; } ];
            actions.update-props = {
              "node.latency" = "512/48000";
              "resample.quality" = 1;
              "api.bluez5.a2dp.bitpool" = 32;
              "api.bluez5.a2dp.ldac.eqmid" = "mq";
              "api.bluez5.transport.send-buffer-size" = 4096;
              "session.suspend-timeout-seconds" = 0; # no pop/delay when audio resumes
              "node.pause-on-idle" = false;
            };
          }
        ];
      };
    };
  };
}
