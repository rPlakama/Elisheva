{pkgs, ...}: {
  # -- User Programs -- #
  environment.systemPackages = with pkgs; [
    bottles
    prismlauncher
  ];
}
