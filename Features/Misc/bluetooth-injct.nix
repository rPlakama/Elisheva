{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.bluetooth-injct;
  wifiDisabled = cfg.disableWifi || cfg.MSIB550Board;
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

    MSIB550Board = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MSI B550M Pro-VDH WiFi hardware tweaks: disables onboard Wi-Fi/PTA, sets iommu=pt, and pins only the B550 chipset xHCI IRQ owning btusb.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Kernel boot parameters
    boot.kernelParams = [
      "btusb.enable_autosuspend=0"
    ]
    ++ lib.optional cfg.boostXhciIrq "threadirqs"
    ++ lib.optional cfg.MSIB550Board "iommu=pt";

    # 2. Clamp default socket buffers to prevent kernel-space L2CAP packet queuing
    boot.kernel.sysctl = {
      "net.core.wmem_default" = lib.mkDefault 32768;
      "net.core.rmem_default" = lib.mkDefault 32768;
    };

    # 3. Wi-Fi RF kill & module blacklisting (auto-enabled when MSIB550Board = true)
    boot.blacklistedKernelModules = lib.mkIf wifiDisabled [
      "iwlwifi"
      "iwlmvm"
      "mt7921e"
    ];
    boot.extraModprobeConfig = lib.mkIf (!wifiDisabled) ''
      options iwlwifi bt_coex_active=0
    '';
    networking.wireless.enable = lib.mkIf wifiDisabled (lib.mkForce false);
    networking.networkmanager.wifi.powersave = lib.mkIf (!wifiDisabled) false;

    systemd.services.bt-wifi-rfkill = lib.mkIf wifiDisabled {
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

    # 5. Systemd hooks: strip default SNIFF/RSWITCH link policy & prioritize xHCI USB IRQ threads
    systemd.services.bluetooth.serviceConfig.ExecStartPost = [
      "-${pkgs.bluez}/bin/hciconfig hci0 lp NONE"
    ];

    systemd.services.bt-xhci-rt-prio = lib.mkIf cfg.boostXhciIrq {
      description = "Pin xHCI USB host controller IRQ threads to SCHED_FIFO 60 for low-latency Bluetooth";
      wantedBy = [ "multi-user.target" ];
      after = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "boost-xhci-irq" (
          if cfg.MSIB550Board then
            ''
              for usbdev in /sys/bus/usb/drivers/btusb/*; do
                [ -e "$usbdev" ] || continue
                pci_path=$(${pkgs.coreutils}/bin/readlink -f "$usbdev" | ${pkgs.gnugrep}/bin/grep -oE '/0000:[0-9a-f:.]+' | ${pkgs.coreutils}/bin/tail -n1)
                [ -n "$pci_path" ] || continue
                pci_dev=$(${pkgs.coreutils}/bin/basename "$pci_path")
                for irq in $(${pkgs.coreutils}/bin/ls "/sys/bus/pci/devices/$pci_dev/msi_irqs/" 2>/dev/null); do
                  for pid in $(${pkgs.procps}/bin/pgrep -f "irq/$irq-"); do
                    ${pkgs.util-linux}/bin/chrt -f -p 60 "$pid" || true
                  done
                done
              done
            ''
          else
            ''
              for pid in $(${pkgs.procps}/bin/pgrep -f "irq/.*xhci_hcd"); do
                ${pkgs.util-linux}/bin/chrt -f -p 60 "$pid" || true
              done
            ''
        );
      };
    };

    # 6. Udev rules: lock USB runtime power to 'on' & dynamically toggle link policy/page-scan on ACL link
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", TEST=="power/control", ATTR{power/control}="on"
    ''
    + lib.optionalString (cfg.deviceMac != null) ''
      ACTION=="add", SUBSYSTEM=="bluetooth", ENV{DEVTYPE}=="link", RUN+="${pkgs.bluez}/bin/hcitool lp ${cfg.deviceMac} NONE", RUN+="${pkgs.bluez}/bin/hciconfig hci0 noscan"
      ACTION=="remove", SUBSYSTEM=="bluetooth", ENV{DEVTYPE}=="link", RUN+="${pkgs.bluez}/bin/hciconfig hci0 pscan"
    '';

    # 7. PipeWire & WirePlumber configuration (318 kbps SBC-XQ @ 48kHz default + LDAC fallback)
    services.pipewire = {
      extraConfig.pipewire."92-sample-rates" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 48000 ];
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 512;
        };
      };

      wireplumber.extraConfig."51-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.default.rate" = 48000;
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [
            "sbc_xq"
            "ldac"
            "aac"
            "sbc"
          ];
        };

        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props = {
              "bluez5.a2dp.ldac.quality" = "mq";
              "bluez5.auto-connect" = [ "a2dp_sink" ];
            };
          }
          {
            matches = [ { "node.name" = "~bluez_output.*"; } ];
            actions.update-props = {
              "node.latency" = "256/48000";
              "resample.quality" = 1;
              "api.bluez5.a2dp.channel-mode" = "joint-stereo";
              "api.bluez5.a2dp.bitpool" = 53;
              "api.bluez5.a2dp.ldac.eqmid" = "mq";
              "api.bluez5.transport.send-buffer-size" = 4096;
              "session.suspend-timeout-seconds" = 0;
              "node.pause-on-idle" = false;
            };
          }
        ];
      };
    };
  };
}
