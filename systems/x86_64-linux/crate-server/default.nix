{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  # TEST CONFIGURATION for crate-server
  # This uses disk-config-test.nix and storage-test.nix
  # for safe testing without touching production data

  imports = [
    ./disk-config.nix # Single 500GB SSD partitioned to simulate full setup
    ./storage.nix # MergerFS with 3 simulated array disks
    ./hardware.nix # Your hardware config (unchanged)
    ./agenix.nix # Your secrets (unchanged)
  ];

  crate = {
    suites.server.enable = true;

    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      extraGroups = ["wheel" "docker" "input"];
      hashedPassword = "$6$0hEDoOmgboCsWYUO$pvKuFdpVIyJYNeLE.Eqg.eGed5ixdvjgDbkdjcpY93XM4aPNj68lyM1yR//7PXNV4Mzz841QII4DYl2.iHo6z.";
    };
  };

  networking = {
    hostName = "crate-server";
    domain = "crate.dev";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22 2222 80 443];
      checkReversePath = "loose";
    };
  };

  # Enable Docker for your containers
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  system.stateVersion = "24.05";
}
