{...}: {
  services.tuned = {
    enable = true;
    settings = {
      daemon = true;
      dynamic_tuning = true;
    };
  };
}
