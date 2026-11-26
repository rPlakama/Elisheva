{ pkgs, ... }:
{
  # Intel Kaby Lake (i5-7600 / HD Graphics 630) & Linux 7.3.5 tuning
  boot = {
    kernelModules = [ "tcp_bbr" ];
    kernelParams = [
      "i915.enable_guc=2" # Enable HuC firmware for Jellyfin VA-API/QSV low-power encoding
      "transparent_hugepage=madvise"
      # Optional security-vs-performance tradeoff (+10-30% syscall/IO on Kaby Lake):
      # "mitigations=off"
    ];

    kernel.sysctl = {
      # Network stack: BBR congestion control + FQ pacing + larger socket buffers
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.core.rmem_max" = 67108864;
      "net.core.wmem_max" = 67108864;
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 15;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    thermald.enable = true;

    nginx.appendHttpConfig = ''
      open_file_cache max=4096 inactive=30s;
      open_file_cache_valid 60s;
      open_file_cache_min_uses 2;
      open_file_cache_errors on;
    '';
  };

  # Prefer defer+madvise for THP defrag to avoid synchronous compaction stalls
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
  ];

  # Tailscale subnet router / exit node UDP GRO forwarding optimization on enp2s0
  systemd.services.tailscale-udp-gro = {
    description = "Enable UDP GRO forwarding on enp2s0 for Tailscale";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "-${pkgs.ethtool}/bin/ethtool -K enp2s0 rx-udp-gro-forwarding on rx-gro-list off";
    };
  };
}
