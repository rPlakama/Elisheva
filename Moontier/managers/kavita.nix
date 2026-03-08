{ inputs, config, ... }:

{
  sops = {
    secrets."kavita_token" = {
      owner = "kavita";
    };
  };
  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets."kavita_token".path;
  };
}
