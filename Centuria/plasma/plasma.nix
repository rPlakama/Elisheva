{...}: {
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "altwin:swap_alt_win";
    };
  };
}
