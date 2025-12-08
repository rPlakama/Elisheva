{ ... }: {

  services.slskd = {
    enable = true;
    domain = "slskd.nix.com";
    openFirewall = true;
  };
}
