{...}: {
  programs = {
    starship.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
