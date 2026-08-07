{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.crate-desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      ../../machines/crate-desktop/hardware.nix
      ../../machines/crate-desktop/disk-config.nix
      ../../machines/crate-desktop/agenix.nix

      self.modules.nixos.role-desktop
      self.modules.nixos.docker
      self.modules.nixos.deploy
      self.modules.nixos.deploy-test-vm
      self.modules.nixos.cachix-push
      self.modules.nixos.android-studio

      {
        # "disk" grants raw access to /dev/disk/by-partlabel/* block
        # devices, needed so QEMU (run as matt, not root) can pass
        # crate-server-vm's cache/array partitions straight through --
        # see packages/deploy-test-vm.
        users.users.matt.extraGroups = ["wheel" "docker" "input" "disk"];

        networking = {
          hostName = "crate-desktop";
          domain = "crate.dev";
          networkmanager.enable = true;
          firewall = {
            enable = false;
            checkReversePath = "loose";
          };
          interfaces.enp5s0.wakeOnLan.enable = true;
        };

        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [
            self.modules.homeManager.role-desktop
            self.modules.homeManager.app-spawn-listener
            self.modules.homeManager.android-studio
            {
              wayland.windowManager.niri.settings.output = [
                {
                  _args = ["HDMI-A-1"];
                  mode = "3840x2160@120";
                  scale = 1.0;
                }
              ];
            }
          ];
        };
      }

      # Bridges enp4s0 (the live LAN NIC -- enp5s0 is unplugged) into br0
      # so QEMU test VMs (see packages/deploy-test-vm) can get their own
      # real LAN IP instead of NAT/port-forwarding -- used for the
      # crate-server rehearsal VM.
      ({pkgs, ...}: {
        networking.networkmanager.ensureProfiles.profiles = {
          br0 = {
            connection = {
              id = "br0";
              type = "bridge";
              interface-name = "br0";
              autoconnect = true;
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
          enp4s0 = {
            connection = {
              id = "enp4s0";
              type = "ethernet";
              interface-name = "enp4s0";
              master = "br0";
              slave-type = "bridge";
              autoconnect = true;
            };
          };
        };

        security.wrappers.qemu-bridge-helper = {
          source = "${pkgs.qemu}/libexec/qemu-bridge-helper";
          owner = "root";
          group = "root";
          setuid = true;
        };

        environment.etc."qemu/bridge.conf".text = "allow br0\n";
      })
    ];
  };
}
