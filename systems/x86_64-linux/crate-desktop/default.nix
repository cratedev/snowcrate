{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  imports = [
    ./disk-config.nix
    ./hardware.nix
    ./agenix.nix
  ];

  crate = {
    archetypes = {
      desktop = enabled;
    };

    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      extraGroups = ["wheel"];
      hashedPassword = "$6$0hEDoOmgboCsWYUO$pvKuFdpVIyJYNeLE.Eqg.eGed5ixdvjgDbkdjcpY93XM4aPNj68lyM1yR//7PXNV4Mzz841QII4DYl2.iHo6z.";
    };
  };

  networking = {
    hostName = "crate-desktop";
    domain = "crate.dev";
    networkmanager.enable = true;
    firewall = {
      enable = false;
      checkReversePath = "loose";
    };
  };

  system.stateVersion = "24.05";
}
