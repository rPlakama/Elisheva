{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    bottles
    lunar-client
  ];
}
