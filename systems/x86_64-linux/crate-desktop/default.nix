{...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "crate-desktop";
    networkmanager.enable = true;
  };

  system.stateVersion = "24.05";
}
