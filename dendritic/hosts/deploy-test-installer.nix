{inputs, ...}: {
  # Minimal installer ISO with matt's SSH keys baked into the "nixos"
  # user's authorized_keys, for deploy-test-vm -- one entry per host that
  # runs deploy-test-vm, since each has its own distinct keypair.
  flake.nixosConfigurations.deploy-test-installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      {
        users.users.nixos.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa4SXR5EFOR97AO858EdPgic2kjFo1i+MSdOzMtj741 matt@crate-desktop"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItETI5nQ1tNxHQ7S7dpDodTU1aT6cPe66+jeS3el9Ac matt@crate-laptop"
        ];
      }
    ];
  };
}
