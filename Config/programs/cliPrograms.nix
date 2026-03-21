{ ... }:
{
  programs = {
    nix-ld.enable = true;
    fish = {
      enable = true;
      generateCompletions = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
