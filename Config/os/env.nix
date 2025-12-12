{ ... }:
{
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shellAliases = {

      sfs = "echo -e 'Rebuild Type: \\033[32m SWITCH \\033[0m'; sudo nixos-rebuild switch --flake .#$HOSTNAME";
      sfb = "echo -e 'Rebuild Type: \\033[32m BOOT \\033[0m'; sudo nixos-rebuild boot --flake .#$HOSTNAME";
      sft = "echo -e 'Rebuild Type: \\033[32m TEST \\033[0m'; sudo nixos-rebuild test --flake .#$HOSTNAME";

      cl = "echo -e 'Cleaning Type: \\033[32m SIMPLE \\033[0m'; sudo nix store gc;";
      cla = "echo -e 'Cleaning Type: \\033[32m ALL \\033[0m'; sudo nix-collect-garbage -d; nix-collect-garbage; nix-store --optimise";

      develop = "nix develop ./.nix-develop-cache-1-link";
      nv = "nvim";

      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}
