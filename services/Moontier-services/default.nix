{
  imports = [
    ./downloaders.nix
    ./media-stack.nix
    ./services-permissions.nix
    ./systemctl.nix
    ./pi-hole.nix
  ];
  sops = {
    # NOTE: <-- I mean it can be inhereted by >>flake<<... But! Only {Moontier} uses this for now.
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
