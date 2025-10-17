{...}: {
  # -- FastFetch -- #
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos";
      };
      modules = [
        "Break"
        "Uptime"
        "Host"
        "OS"
        "Shell"
        "Packages"
        "Break"
        "CPU"
        "GPU"
        "WM"
        "LM"
        "Terminal"
        "TerminalFont"
        "Break"
        "Memory"
        "Disk"
        "Kernel"
      ];
    };
  };
}
