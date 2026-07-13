{
  inputs,
  self,
  ...
}: {
  # NOTE: this host was already marked "TEST CONFIGURATION" on the old
  # branch and explicitly out of scope for fixing beyond obvious eval
  # bugs (see storage.nix's duplicate OnCalendar fix, applied to the
  # source file directly). disk-config.nix's `/dev/sda111` placeholder is
  # carried over unchanged -- it still needs a real device path filled in
  # before this host is deployable.
  flake.nixosConfigurations.crate-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      ../../systems/x86_64-linux/crate-server/hardware.nix
      ../../systems/x86_64-linux/crate-server/disk-config.nix
      ../../systems/x86_64-linux/crate-server/storage.nix
      ../../systems/x86_64-linux/crate-server/agenix.nix

      self.modules.nixos.suite-server
      self.modules.nixos.docker

      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          inputs.niri.overlays.niri
          (import ../../overlays/zellij-plugins {})
        ];

        users.users.matt.extraGroups = ["wheel" "docker" "input"];

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

        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [self.modules.homeManager.profile-server];
        };
      }
    ];
  };
}
