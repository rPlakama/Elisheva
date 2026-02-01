{ inputs, config, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../network/secrets.yaml;
    secrets."kavita_token" = {
      owner = "kavita";
    };
  };
  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets."kavita_token".path;
  };
}
