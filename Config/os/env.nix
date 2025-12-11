{ ... }:
{
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shellAliases = {
      develop = "nix develop ./.nix-develop-cache-1-link";
      sfs = "echo 'Rebuilding system as SWITCH'
      sudo nixos-rebuild switch --flake .#HOSTNAME";
      sfb = "echo 'Rebulding system as BOOT'
      sudo nixos-rebuild boot --flake .#HOSTNAME";
      nv = "nvim";
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}
