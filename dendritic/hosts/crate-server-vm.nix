{
  inputs,
  self,
  ...
}: {
  # Test-only twin of crate-server: same modules, but pointed at QEMU
  # NVMe devices instead of the real hardware's by-id serials. See
  # packages/deploy-test-vm. Never deploy this to real hardware.
  flake.nixosConfigurations.crate-server-vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      ../../machines/crate-server/hardware.nix
      ../../machines/crate-server/disk-config.nix
      ../../machines/crate-server/storage.nix
      ../../machines/crate-server/agenix.nix

      self.modules.nixos.role-server
      self.modules.nixos.docker
      self.modules.nixos.cockpit
      self.modules.nixos.komodo-periphery
      self.modules.nixos.unraid-compose

      {
        users.users.matt.extraGroups = ["wheel" "docker" "input" "video" "render"];

        # nvme0n1 is the dedicated "boot card" disk; nvme1n1/nvme2n1 are
        # the cache pair; nvme3n1..nvme11n1 are the 9 array disks. Order
        # matches packages/deploy-test-vm's QEMU device wiring.
        crate.storage.crateServer = {
          bootDevice = "/dev/nvme0n1";
          cacheAppdataDevice = "/dev/nvme1n1";
          cacheDataDevice = "/dev/nvme2n1";
          arrayDisks = {
            disk1 = "/dev/nvme3n1";
            disk2 = "/dev/nvme4n1";
            disk3 = "/dev/nvme5n1";
            disk4 = "/dev/nvme6n1";
            disk5 = "/dev/nvme7n1";
            disk6 = "/dev/nvme8n1";
            disk7 = "/dev/nvme9n1";
            disk8 = "/dev/nvme10n1";
            disk9 = "/dev/nvme11n1";
          };
        };

        networking = {
          hostName = "crate-server-vm";
          domain = "crate.dev";
          networkmanager = {
            enable = true;
            # Static LAN IP over DHCP, matched by the fixed MAC set on the
            # QEMU virtio-net device (see packages/deploy-test-vm), so
            # containers here are reachable at 10.0.0.60:<port> from
            # crate-laptop instead of needing per-port NAT forwarding.
            ensureProfiles.profiles.lan = {
              connection = {
                id = "lan";
                type = "ethernet";
                autoconnect = true;
              };
              ethernet.mac-address = "52:54:00:12:34:60";
              ipv4 = {
                method = "manual";
                address1 = "10.0.0.60/24,10.0.0.1";
                dns = "10.0.0.1;";
              };
              ipv6.method = "ignore";
            };
          };
          firewall = {
            enable = true;
            allowedTCPPorts = [22 2222 80 443 3552 9120];
            checkReversePath = "loose";
          };
        };

        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [self.modules.homeManager.role-server];
        };
      }
    ];
  };
}
