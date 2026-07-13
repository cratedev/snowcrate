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

      # Host-specific raw config reused as-is from the pre-existing
      # (snowfall-lib) system definition -- unchanged, not duplicated.
      ../../machines/crate-laptop/hardware.nix
      ../../machines/crate-laptop/disk-config.nix
      ../../machines/crate-laptop/agenix.nix

      self.modules.nixos.suite-laptop

      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          inputs.niri.overlays.niri
          (import ../../overlays/zellij-plugins {})
        ];

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

        virtualisation.libvirtd.enable = true;
        hardware.bluetooth.enable = true;
        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [
            self.modules.homeManager.profile-laptop
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
