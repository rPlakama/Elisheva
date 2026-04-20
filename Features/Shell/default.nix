{
  config,
  pkgs,
  ...
}:

let
  user = config.core.user;
in
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

  environment.systemPackages = with pkgs; [
    yazi
  ];

  hjem.users.${user} = {
    enable = true;

    xdg.config.files = {
      "fish/config.fish".source = ./config.fish;
      "yazi/yazi.toml".source = ./yazi.toml;
      "yazi/keymap.toml".source = ./keymap.toml;
    };
  };
}
