{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  featureCall = config.features;
  domain = config.core.domain;
  port = 5930;
in
{
  imports = [ inputs.localrevisor.nixosModules.default ];

  options.features.localrevisor.enable = lib.mkEnableOption "localRevisor module";

  config = lib.mkIf featureCall.localrevisor.enable {
    features = {
      preservation.system.directories = [ "/var/lib/localrevisor" ];
      unifiedDNS.proxyServices.localrevisor = {
        port = port;
        description = "ENEM essay grading service";
      };
    };
    services.localrevisor = {
      enable = true;
      inherit port;
      package = inputs.localrevisor.packages.${pkgs.stdenv.hostPlatform.system}.default;
      trustedHosts = [ "localrevisor.${domain}" ];
    };
  };
}
