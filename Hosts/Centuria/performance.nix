{ pkgs, ... }:
{
  # AMD Ryzen + NVIDIA Desktop (NVMe BTRFS + tmpfs + Sunshine) & Linux 7.3.5 tuning
  boot = {
    kernelModules = [
      "tcp_bbr"
      "nf_conntrack"
    ];
    kernelParams = [
      "amd_pstate=active" # Hardware-managed P-states + EPP for Ryzen boost scaling
      "nvme_core.default_ps_max_latency_us=0" # Disable NVMe deep sleep latency on AC desktop
      "transparent_hugepage=madvise"
    ];

    kernel.sysctl = {
      # Gaming, emulation (Steam/Proton/Lichii) & VM housekeeping
      "vm.max_map_count" = 2147483642;
      "vm.stat_interval" = 10;
      "vm.compaction_proactiveness" = 0;
      "kernel.nmi_watchdog" = 0;

      # Desktop/sync/IDE inotify headroom
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 1024;
      "fs.inotify.max_queued_events" = 32768;

      # Network stack: BBR + FQ + Sunshine low-latency streaming + bpftune baseline
      # (wmem_default / rmem_default intentionally left to bluetooth-injct = 32768)
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
      "net.netfilter.nf_conntrack_max" = 262144;
    };
  };

  nix.gc.randomizedDelaySec = "45m";

  services = {
    # Linux 7.3.5 sched_ext: scx_lavd prioritizes latency-critical games, Sunshine & audio
    scx-loader = {
      enable = true;
      config = {
        default_sched = "scx_lavd";
        default_mode = "Auto";
      };
    };

    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    bpftune.enable = true;
    irqbalance.enable = true;

    # Monthly scrub on the BTRFS pool (/nix and /persistent share one filesystem)
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/persistent" ];
    };

    # Guard RAM carefully since / is tmpfs (size=40%)
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
    };

    journald.settings.Journal = {
      SystemMaxUse = "200M";
      RuntimeMaxUse = "64M";
      Compress = true;
    };
  };

  # Prevent massive game/emulator crash dumps from eating tmpfs/NVMe
  systemd.coredump.enable = false;

  # THP defer+madvise & MGLRU 1s working-set protection
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  ];

  # Keep background syncthing from causing 1% low drops during gaming or Sunshine streaming
  systemd.services.syncthing = {
    environment = {
      GOMAXPROCS = "2";
      GOMEMLIMIT = "384MiB";
    };
    serviceConfig = {
      CPUWeight = 20;
      Nice = 15;
      IOWeight = 10;
      IOSchedulingClass = "idle";
    };
  };
}
