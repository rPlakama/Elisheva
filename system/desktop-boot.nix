{ lib, isElisheva, ... }:
{

  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
    };

    kernelParams = [
      "amd_pstate=active"
      "kvm-amd" # <-- NOTE:  android-studio.
    ]
    ++ lib.optionals isElisheva [
      "video=eDP-1:1920x1080@72" # <-- Shitty Screen
    ];
  };
}
