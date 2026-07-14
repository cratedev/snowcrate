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

      {
        users.users.matt.extraGroups = ["wheel" "docker" "input"];

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
    ];
  };
}
