{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qimgv
    onlyoffice-desktopeditors
  ];
}
