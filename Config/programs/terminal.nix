{ ... }:
{
  programs = {
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
