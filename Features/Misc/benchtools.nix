{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  featureCall = config.features;
in
{

  options.features.benchtools.enable = lib.mkEnableOption "Benchmark tools";

  config = lib.mkIf featureCall.benchtools.enable {
    environment.systemPackages = with pkgs; [
      stress-ng
      passmark-performancetest
      geekbench_7
      inputs.twatch.packages.${pkgs.stdenv.hostPlatform.system}.default

    ];
  };
}
