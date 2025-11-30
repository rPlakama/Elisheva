{...}: {
  boot = {
    loader.systemd-boot.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };
}
