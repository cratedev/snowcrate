{inputs, ...}: {
  # A custom NixOS installer ISO for deploy-test-vm, built (not
  # downloaded) so it can have matt@crate-desktop's own SSH public key
  # baked into the "nixos" user's authorized_keys. The stock minimal
  # ISO from nixos.org has no password set for that user at all (this
  # is documented, expected NixOS installer behavior, not a bug) --
  # fine for an interactive install, but nixos-anywhere needs
  # non-interactive key-based auth to connect. Same key already
  # trusted by every real host's authorizedKeys (see openssh.nix).
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
