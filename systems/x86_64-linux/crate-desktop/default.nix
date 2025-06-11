{
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  newUser = name: {
    isNormalUser = true;
    createHome = true;
    home = "/home/${name}";
    shell = pkgs.nushell;
  };
in {
  imports = [
    ./hardware.nix
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

  #  fileSystems."/home/matt/unraid-ssh" = {
  #    device = "root@10.0.0.10:/mnt";
  #    fsType = "fuse.sshfs";
  #    options = [
  #      "nodev"
  #      "noatime"
  #      "allow_other"
  #      "IdentityFile=/home/matt/.ssh/id_ed25519"
  #    ];
  #  };
  system.stateVersion = "24.05";
}
