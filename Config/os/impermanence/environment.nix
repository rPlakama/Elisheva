{ ... }:
{
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/slskd/"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.rplakama = {
      directories = [
        ".config/nvim"
        ".local/share/nvim"
        ".local/state/nvim"
        ".config/vesktop"
        ".mozilla"
        "Downloads"
        "Torrents"
        "Dropbox"
        "Music"
        "Pictures"
        "Documents"
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".local/share/TelegramDesktop";
          mode = "0700";
        }
      ];
      files = [
        ".local/share/fish/fish_history"
        ".config/DankMaterialShell/settings.json"
      ];
    };
  };
}
