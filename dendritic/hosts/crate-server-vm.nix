{
  inputs,
  self,
  ...
}: {
  # Test-only twin of crate-server: same modules, but pointed at QEMU's
  # own by-id NVMe serials instead of the real hardware's. See
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

        # Rehearsal-only: should just run Arcane, not the full production
        # stack. Doesn't stop Komodo if it's already running from before
        # this was set -- see the README note on unraid-compose.service.
        crate.unraidCompose.enableKomodo = false;

        # /dev/nvmeXn1 naming is assigned by kernel probe order, which
        # isn't guaranteed to match QEMU's command-line device order when
        # there are several identical NVMe controllers -- confirmed to
        # actually shift between boots on this VM. Use the by-id paths
        # QEMU derives from each device's serial= (set in
        # packages/deploy-test-vm) instead, same as real crate-server
        # hardware already does with its own by-id serials. The boot disk
        # is ephemeral (recreated each test run); the other four are
        # real, already-formatted partitions on crate-desktop's dedicated
        # 3TB rehearsal drive -- mimicking only 2 array disks, not the
        # real hardware's 9.
        crate.storage.crateServer = {
          bootDevice = "/dev/disk/by-id/nvme-QEMU_NVMe_Ctrl_srv-boot";
          cacheAppdataDevice = "/dev/disk/by-id/nvme-QEMU_NVMe_Ctrl_srv-cache-appdata";
          cacheDataDevice = "/dev/disk/by-id/nvme-QEMU_NVMe_Ctrl_srv-cache-data";
          arrayDisks = {
            disk1 = "/dev/disk/by-id/nvme-QEMU_NVMe_Ctrl_srv-array-disk1";
            disk2 = "/dev/disk/by-id/nvme-QEMU_NVMe_Ctrl_srv-array-disk2";
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
