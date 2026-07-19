{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.crate-server = inputs.nixpkgs.lib.nixosSystem {
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

      {
        users.users.matt.extraGroups = ["wheel" "docker" "input" "video" "render"];

        networking = {
          hostName = "crate-server";
          domain = "crate.dev";
          networkmanager.enable = true;
          firewall = {
            enable = true;
            # 3552/9120 match Arcane/Komodo's current unraid port mappings.
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
