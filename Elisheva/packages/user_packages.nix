{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
  qimgv
];
}
