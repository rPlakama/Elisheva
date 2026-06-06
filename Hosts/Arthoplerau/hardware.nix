{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  boot.kernelModules = [ "kvm-amd" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.pipewire.wireplumber.extraConfig = {
    "10-alsa-fallback" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "device.name" = "~alsa_card.*"; }
          ];
          actions = {
            update-props = {
              "api.alsa.use-ucm" = false;
            };
          };
        }
        {
          matches = [
            { "node.name" = "~alsa_input.*"; }
          ];
          actions = {
            update-props = {
              "audio.format" = "S32_LE";
              "audio.rate" = 48000;
              "audio.channels" = 2;
            };
          };
        }
      ];
    };
  };
}
