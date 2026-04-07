{ config, ... }:
{

  sops = {

    secrets = {
      "newt/endpoint" = { };
      "newt/id" = { };
      "newt/secret" = { };
    };

    templates."newt.env".content = ''
      PANGOLIN_ENDPOINT=${config.sops.placeholder."newt/endpoint"}
      NEWT_ID=${config.sops.placeholder."newt/id"}
      NEWT_SECRET=${config.sops.placeholder."newt/secret"}
    '';
  };

  services.newt = {
    enable = true;
    environmentFile = config.sops.templates."newt.env".path;
  };
}
