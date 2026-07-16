{inputs, ...}: {
  # Minimal installer ISO with matt@crate-desktop's SSH key baked into
  # the "nixos" user's authorized_keys, for deploy-test-vm.
  flake.nixosConfigurations.deploy-test-installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      {
        users.users.nixos.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa4SXR5EFOR97AO858EdPgic2kjFo1i+MSdOzMtj741 matt@crate-desktop"
        ];
      }
    ];
  };
}
