{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.crate-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      ../../machines/crate-laptop/hardware.nix
      ../../machines/crate-laptop/disk-config.nix
      ../../machines/crate-laptop/agenix.nix

      self.modules.nixos.role-laptop
      self.modules.nixos.bluetooth
      self.modules.nixos.libvirtd

      {
        users.users.matt.extraGroups = ["wheel" "input"];

        networking = {
          hostName = "crate-laptop";
          domain = "crate.dev";
          networkmanager.enable = true;
          firewall = {
            enable = false;
            checkReversePath = "loose";
          };
        };

        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [
            self.modules.homeManager.role-laptop
            {
              programs.niri.settings.outputs."eDP-1" = {
                mode = {
                  width = 1920;
                  height = 1200;
                  refresh = 60.0;
                };
                scale = 1.0;
              };
            }
          ];
        };
      }
    ];
  };
}
