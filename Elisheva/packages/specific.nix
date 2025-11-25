{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qimgv
    wpsoffice
    onlyoffice-desktopeditors
  ];
}
