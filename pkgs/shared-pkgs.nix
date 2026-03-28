{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fzf
    dust
    git
    jq
  ];
}
