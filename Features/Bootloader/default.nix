{ ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;
  boot = {
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 0;
    };
  };
}
