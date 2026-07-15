{
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

  # agenix places sshUserKey at /persist/home/matt/.ssh/id_ed25519 during
  # activation, mkdir -p'ing parent directories as root along the way --
  # that doesn't retroactively fix ownership on the dirs it creates, so
  # /persist/home/matt (and therefore the bind-mounted /home/matt) ends
  # up root-owned. tmpfiles' Z type recursively corrects ownership and
  # runs very early in boot, before agenix's own activation script.
  systemd.tmpfiles.rules = ["Z /persist/home/matt 0755 matt users -"];
}
