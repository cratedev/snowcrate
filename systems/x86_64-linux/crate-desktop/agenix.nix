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
        file = "${inputs.mysecrets}/secrets/desktop/ssh_host_ed25519_key.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key"; # persist for ssh
        mode = "600";
        owner = "root";
        group = "root";
      };
      sshHostKeyPub = {
        file = "${inputs.mysecrets}/secrets/desktop/ssh_host_ed25519_key.pub.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key.pub"; # persist for ssh
        mode = "644";
        owner = "root";
        group = "root";
      };
      sshUserKey = {
        file = "${inputs.mysecrets}/secrets/desktop/id_ed25519.age";
        path = "/persist/home/matt/.ssh/id_ed25519";
        mode = "400";
        owner = "matt";
        group = "users";
      };
      sshUserKeyPub = {
        file = "${inputs.mysecrets}/secrets/desktop/id_ed25519_pub.age";
        path = "/persist/home/matt/.ssh/id_ed25519.pub";
        mode = "600";
        owner = "matt";
        group = "users";
      };
    };
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/deployment_key"
    ];
  };

  # I don't know why my homeDir becomes owned by root... this is a future-me problem
  system.activationScripts.deploySshKeys = lib.stringAfter ["users"] ''
    chown -R matt:users /home/matt
  '';
}
