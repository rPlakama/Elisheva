{...}: {
  services.flatpak.packages = [
    {
      appId = "org.telegram.desktop";
      origin = "flathub";
    }
  ];
}
