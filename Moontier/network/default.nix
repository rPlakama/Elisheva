{
  imports = [
    ./jellyfin.nix
    ./cloudflared.nix
  ];
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
  };
}
