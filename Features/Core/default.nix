{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.core.features.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Essential system segments";
  };
  config = lib.mkIf config.core.features.core.enable {
    security.sudo-rs.enable = true;
    environment.systemPackages = with pkgs; [
      wl-clipboard
      ripgrep
      wget
      age
      sops
      git
      unzip
      dust
      jq
      fd
    ];
    fonts.packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      montserrat
      arkpandora_ttf
    ];
    networking.networkmanager.enable = true;
    services = {

      upower.enable = true;
      bpftune.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      tailscale = {
        enable = true;
        openFirewall = true;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };
  };
}
