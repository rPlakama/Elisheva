{ ... }:
{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "nvim +Man!";
    };
    shellAliases = {

      sfs = "echo -e 'Rebuild Type: \033[32m SWITCH \033[0m'; nh os switch . -- --nom";
      sfb = "echo -e 'Rebuild Type: \033[32m BOOT \033[0m'; nh os boot . -- --nom";
      sft = "echo -e 'Rebuild Type: \033[32m TEST \033[0m'; nh os test . -- --nom";
      nf = "echo -e 'Checking for: \033[32m FLAKE \033[0m'; nix flake check .";

      cl = "echo -e 'Cleaning Type: \033[32m SIMPLE \033[0m'; nh clean all --keep 3";
      cla = "echo -e 'Cleaning Type: \033[32m ALL \033[0m'; sudo nix-collect-garbage -d; nix-collect-garbage; nix-store --optimise";

      develop = "nix develop ./.nix-develop-cache-1-link";
      nv = "nvim";

      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}
