{ ... }:

{
  networking = {
    nameservers = [
      "1.1.1.1" # <-- Bypass ISP prohibitions.
      "8.8.8.8"
    ];
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ]; # <-- for any moontier:*
    };
    networkmanager.enable = true;
  };
}
