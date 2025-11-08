{...}: {
  services.cliphist = {
    enable = true;
    extraOptions = [
      "-max-dedupe-search"
      "10"
      "-max-items"
      "500"
    ];
  };
}
