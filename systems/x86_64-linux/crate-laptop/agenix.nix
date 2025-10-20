{
  config,
  lib,
  inputs,
  ...
}: {
  age.secrets = {
    userSshKey = {
      file = inputs.mysecrets + /secrets/laptop/id_ed25519.age;
    };
    userSshKeyPub = {
      file = inputs.mysecrets + /secrets/laptop/id_ed25519_pub.age;
    };
    hostSshKey = {
      file = inputs.mysecrets + /secrets/laptop/ssh_host_ed25519_key.age;
    };
    hostSshKeyPub = {
      file = inputs.mysecrets + /secrets/laptop/ssh_host_ed25519_key.pub.age;
    };
  };

  # EARLY: Deploy keys (impermanence will keep them)
  system.activationScripts.deploySshKeys = lib.stringAfter ["users"] ''
    # Host keys
    mkdir -p /persist/etc/ssh
    rm -f /persist/etc/ssh/ssh_host_ed25519_key*
    cp ${config.age.secrets.hostSshKey.path} /persist/etc/ssh/ssh_host_ed25519_key
    cp ${config.age.secrets.hostSshKeyPub.path} /persist/etc/ssh/ssh_host_ed25519_key.pub
    chmod 600 /persist/etc/ssh/ssh_host_ed25519_key
    chmod 644 /persist/etc/ssh/ssh_host_ed25519_key.pub
    chown root:root /persist/etc/ssh/ssh_host_ed25519_key*

    # User keys (root + matt)
    mkdir -p /root/.ssh /persist/home/matt/.ssh
    cp ${config.age.secrets.userSshKey.path} /persist/home/matt/.ssh/id_ed25519
    cp ${config.age.secrets.userSshKeyPub.path} /persist/home/matt/.ssh/id_ed25519.pub
    chmod 600 /persist/home/matt/.ssh/id_ed25519
    chmod 644 /persist/home/matt/.ssh/id_ed25519.pub
    chown matt:users /persist/home/matt/.ssh/id_ed25519*
  '';

  services.openssh.hostKeys = lib.mkForce [
    {
      type = "ed25519";
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
    }
  ];
}
