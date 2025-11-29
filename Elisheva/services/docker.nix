{ ... }: {
  virtualisation.docker.enable = true;
  users.users.rplakama.extraGroups = [ "docker" ];
}
