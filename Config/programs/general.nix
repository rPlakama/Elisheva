{ ... }:
{
  programs = {
    firefox.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
