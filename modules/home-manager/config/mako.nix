{...}: {
  # -- Configuration Of Mako -- #
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 2;
      border-size = 0;
      layer = "overlay";
    };
  };
}
