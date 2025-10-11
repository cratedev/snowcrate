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
    shell = pkgs.zsh;
  };
in {
  imports = [
    ./hardware.nix
    ./disk-config.nix
  ];

  crate = {
    archetypes = {
      laptop = enabled;
    };
    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      extraGroups = ["wheel"];
      hashedPassword = "$6$0hEDoOmgboCsWYUO$pvKuFdpVIyJYNeLE.Eqg.eGed5ixdvjgDbkdjcpY93XM4aPNj68lyM1yR//7PXNV4Mzz841QII4DYl2.iHo6z.";
    };
  };

  # Install Git for cloning
  environment.systemPackages = [pkgs.git];

  # Activation script to clone snowcrate if missing
  system.activationScripts.cloneSnowcrate = {
    text = ''
      if [ ! -d /home/matt/snowcrate ]; then
        mkdir -p /home/matt/snowcrate
        chown matt:users /home/matt/snowcrate
        ${pkgs.git}/bin/git clone https://github.com/cratedev/snowcrate /home/matt/snowcrate
      fi
    '';
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
  hardware.bluetooth.enable = false;

  fileSystems."/home/matt/unraid-ssh" = {
    device = "root@10.0.0.10:/mnt";
    fsType = "fuse.sshfs";
    options = [
      "nodev"
      "noatime"
      "allow_other"
      "IdentityFile=/home/matt/.ssh/id_ed25519"
    ];
  };

  system.stateVersion = "24.05";
}
