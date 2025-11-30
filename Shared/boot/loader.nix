{...}: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };
}
