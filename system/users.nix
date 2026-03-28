{
  lib,
  isDesktop,
  pkgs,
  ...
}:
{
  users.users.rplakama = {
    isNormalUser = true;
    description = "rPlakama.";
    extraGroups = [
      "wheel"
      "networkmanager"
    ]
    ++ lib.optionals isDesktop [
      "libvirtd" # <-- KVM.
      "docker"

    ];
    shell = pkgs.fish;
  };
}
