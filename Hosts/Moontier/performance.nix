{ pkgs, ... }:
{
  # Intel Kaby Lake (i5-7600 / HD Graphics 630) & Linux 7.3.5 tuning
  boot = {
    kernelModules = [
      "tcp_bbr"
      "nf_conntrack"
    ];
    kernelParams = [
      "i915.enable_guc=2" # Enable HuC firmware for Jellyfin VA-API/QSV low-power encoding
      "transparent_hugepage=madvise"
      # Optional security-vs-performance tradeoff (+10-30% syscall/IO on Kaby Lake):
      # "mitigations=off"
    ];

    kernel.sysctl = {
      # Headless EEVDF scheduler & kernel housekeeping
      "kernel.sched_autogroup_enabled" = 0; # Respect systemd cgroup weights over TTY sessions
      "kernel.nmi_watchdog" = 0; # Free 1 PMU counter/core and drop periodic NMI jitter
      "vm.stat_interval" = 10; # Reduce VM stats aggregation wakeups (1s -> 10s)
      "vm.compaction_proactiveness" = 0; # Avoid background kcompactd CPU spikes with THP madvise

      # Media/sync inotify headroom (Syncthing, Jellyfin, Navidrome, Kavita, Sonarr, Radarr)
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 1024;
      "fs.inotify.max_queued_events" = 32768;

      # Network stack: BBR + FQ pacing + persistent HTTP/2 & Tailscale/P2P tuning
      # (Used as baseline by bpftune, which scales dynamically from here)
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_notsent_lowat" = 16384;
      "net.core.rmem_max" = 33554432;
      "net.core.wmem_max" = 33554432;
      "net.ipv4.tcp_rmem" = "4096 87380 33554432";
      "net.ipv4.tcp_wmem" = "4096 65536 33554432";
      "net.core.somaxconn" = 8192;
      "net.core.netdev_max_backlog" = 16384;
      "net.core.netdev_budget" = 600;
      "net.core.netdev_budget_usecs" = 8000;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 15;
      "net.ipv4.ip_local_port_range" = "10240 65535";
      "net.netfilter.nf_conntrack_max" = 262144;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  nix.gc.randomizedDelaySec = "45m";

  services = {
    bpftune.enable = true;
    irqbalance.enable = true;
    thermald.enable = true;

    nginx = {
      eventsConfig = ''
        worker_connections 2048;
        multi_accept on;
      '';
      appendHttpConfig = ''
        keepalive_requests 1000;
        open_file_cache max=4096 inactive=30s;
        open_file_cache_valid 60s;
        open_file_cache_min_uses 2;
        open_file_cache_errors on;
      '';
    };
  };

  # Prevent multi-hundred-MB .NET/Python/Chromium crash dumps from stalling the HDD
  systemd.coredump.enable = false;

  # THP defer+madvise & MGLRU 1s active working-set floor (protects hot cache from scan eviction)
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  ];

  # Tailscale UDP GRO forwarding & NIC ring buffer tuning on enp2s0
  systemd.services.tailscale-udp-gro = {
    description = "Enable UDP GRO forwarding and ring tuning on enp2s0";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "-${pkgs.ethtool}/bin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off"
        "-${pkgs.ethtool}/bin/ethtool -G enp2s0 rx 4096 tx 4096"
      ];
    };
  };
}
