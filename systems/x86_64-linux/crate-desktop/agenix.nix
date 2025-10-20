{
  config,
  inputs,
  ...
}: {
  # Import agenix module (adjust if defined in modules/nixos/tools/impermanence)
  imports = [
    inputs.agenix.nixosModules.default
  ];

  # Agenix configuration
  age = {
    secrets = {
      sshHostKey = {
        file = "${inputs.mysecrets}/secrets/desktop/ssh_host_ed25519_key.age";
        path = "/persist/etc/ssh/ssh_host_ed25519_key"; # Persist for SSH
        mode = "600";
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

      # Add other secrets (e.g., user SSH keys) as needed
    };
    identityPaths = [
      "/persist/deployment_key" # Where we'll deploy the private key
    ];
  };

  # Impermanence for /etc/ssh and other paths
  environment.persistence."/persist" = {
    files = [
      "/persist/deployment_key" # Persist the deployment key
    ];
  };

  # SSH configuration (let nixos-anywhere generate keys)
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
