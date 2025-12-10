{ ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = "
    function fish_greeting
    echo Time is: (set_color yellow)(date +%T)(set_color normal) and we are in $hostname
end
";
  };
}
