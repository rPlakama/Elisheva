{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qimgv
    kdePackages.dolphin
  ];
}
