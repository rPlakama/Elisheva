{
  isElisheva,
  ...
}:
{
  services = {
    upower.enable = true;
    bpftune.enable = true;

    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = if isElisheva then [ "--powersave" ] else [ ];
    };

    devmon.enable = true;
    udisks2.enable = true;
  };

}
