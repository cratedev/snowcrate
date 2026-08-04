shortName: {
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  # Lets `sudo nixos-rebuild switch/test` (and anything else run as root)
  # fetch the private nix-secrets flake input over SSH -- root has no SSH
  # access of its own, so without this, evaluating as root fails outright
  # (nothing to do with the secrets themselves; the whole flake input
  # fetch never gets that far). matt's own key already has nix-secrets
  # access, so system-wide config just points root at the same key
  # (readable by root regardless of its 400/matt:users mode). This is
  # system-wide rather than root-only because there's no per-user config
  # to override it with here, and it doesn't weaken anything -- it's the
  # exact same key matt's own shell already uses for this host.
  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ${config.age.secrets.sshUserKey.path}
      IdentitiesOnly yes
  '';

  age = {
    secrets = {
      sshHostKey = {
        file = "${inputs.mysecrets}/secrets/${shortName}/ssh_host_ed25519_key.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        mode = "600";
        owner = "root";
        group = "root";
      };
      sshHostKeyPub = {
        file = "${inputs.mysecrets}/secrets/${shortName}/ssh_host_ed25519_key.pub.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
        mode = "644";
        owner = "root";
        group = "root";
      };
      sshUserKey = {
        file = "${inputs.mysecrets}/secrets/${shortName}/id_ed25519.age";
        path = "/persist/home/matt/.ssh/id_ed25519";
        mode = "400";
        owner = "matt";
        group = "users";
      };
      sshUserKeyPub = {
        file = "${inputs.mysecrets}/secrets/${shortName}/id_ed25519_pub.age";
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
      cachix-env = {
        file = "${inputs.mysecrets}/secrets/env/cachix.age";
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

  # Corrects /persist/home/matt ownership left root-owned by agenix's
  # activation script (mkdir -p'd as root when creating intermediate
  # paths for decrypted secrets). Lowercase z is deliberate -- it fixes
  # just this directory, not recursively: uppercase Z previously forced
  # 0755 onto every file underneath on every boot, clobbering whatever
  # mode git (or anything else) actually expected.
  systemd.tmpfiles.rules = ["z /persist/home/matt 0755 matt users -"];
}
