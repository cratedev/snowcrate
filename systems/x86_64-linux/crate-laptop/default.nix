{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./hardware.nix
    ./disk-config.nix
    ./agenix.nix
  ];

  crate = {
    suites.laptop.enable = true;
    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      extraGroups = ["wheel"];
      hashedPassword = "$6$0hEDoOmgboCsWYUO$pvKuFdpVIyJYNeLE.Eqg.eGed5ixdvjgDbkdjcpY93XM4aPNj68lyM1yR//7PXNV4Mzz841QII4DYl2.iHo6z.";
    };
  };

  networking = {
    hostName = "crate-laptop";
    domain = "crate.dev";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      checkReversePath = "loose";
    };
  };

  virtualisation.libvirtd.enable = true;
  hardware.bluetooth.enable = true;

  system.stateVersion = "24.05";
}
