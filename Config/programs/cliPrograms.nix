{ ... }:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
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
