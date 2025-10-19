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

  # Rest of your activation scripts (unchanged)
  system.activationScripts.deployHostKey = lib.stringAfter ["agenix"] ''
    mkdir -p /etc/ssh
    cp ${config.age.secrets.hostSshKey.path} /etc/ssh/ssh_host_ed25519_key
    chmod 600 /etc/ssh/ssh_host_ed25519_key
    chown root:root /etc/ssh/ssh_host_ed25519_key
    cp ${config.age.secrets.hostSshKeyPub.path} /etc/ssh/ssh_host_ed25519_key.pub
    chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
  '';

  system.activationScripts.deployUserKeys = lib.stringAfter ["deployHostKey"] ''
    mkdir -p /home/matt/.ssh
    cp ${config.age.secrets.userSshKey.path} /home/matt/.ssh/id_ed25519
    chmod 600 /home/matt/.ssh/id_ed25519
    cp ${config.age.secrets.userSshKeyPub.path} /home/matt/.ssh/id_ed25519.pub
    chmod 644 /home/matt/.ssh/id_ed25519.pub
  '';

  #  services.openssh.hostKeys = [{
  #    type = "ed25519";
  #    path = "/etc/ssh/ssh_host_ed25519_key";
  #  }];
}
