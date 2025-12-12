{ ... }:
{
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shellAliases = {
      develop = "nix develop ./.nix-develop-cache-1-link";
      sfs = "echo -e 'Rebuild Type: \\033[32m SWITCH \\033[0m'; sudo nixos-rebuild switch --flake .#$HOSTNAME";
      sfb = "echo -e 'Rebuild Type: \\033[32m BOOT \\033[0m'; sudo nixos-rebuild boot --flake .#$HOSTNAME";
      sft = "echo -e 'Rebuild Type: \\033[32m TEST \\033[0m'; sudo nixos-rebuild test --flake .#$HOSTNAME";
      nv = "nvim";
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}
