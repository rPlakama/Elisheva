{ ... }: {
programs.bash = {
  enable = true;
    interactiveShellInit = "
      set -o vi
    ";
  };
}
