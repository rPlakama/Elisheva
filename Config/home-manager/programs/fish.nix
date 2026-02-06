{ ... }:
{
  programs.fish = {
    enable = true;
    shellInit = "
          function fish_greeting
end
fish_vi_key_bindings
";
  };
}
