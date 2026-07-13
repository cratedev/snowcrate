{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    secrets = {
      sshHostKey = {
        file = "${inputs.mysecrets}/secrets/server/ssh_host_ed25519_key.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        mode = "600";
        owner = "root";
        group = "root";
      };
      sshHostKeyPub = {
        file = "${inputs.mysecrets}/secrets/server/ssh_host_ed25519_key.pub.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
        mode = "644";
        owner = "root";
        group = "root";
      };
      sshUserKey = {
        file = "${inputs.mysecrets}/secrets/server/id_ed25519.age";
        path = "/persist/home/matt/.ssh/id_ed25519";
        mode = "400";
        owner = "matt";
        group = "users";
      };
      sshUserKeyPub = {
        file = "${inputs.mysecrets}/secrets/server/id_ed25519_pub.age";
        path = "/persist/home/matt/.ssh/id_ed25519.pub";
        mode = "600";
        owner = "matt";
        group = "users";
      };
      # suite-base (pulled in via suite-server) unconditionally references
      # this via the beszel aspect. Was missing here entirely on the old
      # branch too -- crate-server was never build-tested before this
      # migration. Shared file, same as crate-desktop/crate-laptop's
      # agenix.nix (not host-specific, unlike the ssh secrets above).
      beszel-env = {
        file = "${inputs.mysecrets}/secrets/env/beszel.age";
        mode = "400";
        owner = "matt";
        group = "users";
      };
    };
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/deployment_key"
    ];
  };

  system.activationScripts.deploySshKeys = lib.stringAfter ["users"] ''
    chown -R matt:users /home/matt
  '';
}
