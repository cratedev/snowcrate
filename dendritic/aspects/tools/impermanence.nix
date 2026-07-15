{inputs, ...}: {
  flake.modules.nixos.impermanence = {...}: {
    imports = [inputs.impermanence.nixosModules.impermanence];

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/log"
        "/etc/NetworkManager/system-connections"
        "/var/lib/tailscale"
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];

      users.matt = {
        directories = [
          "snowcrate"
          "documents"
          "media"
          ".config/dconf"
          {
            directory = "whiskeyvault";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
        ];

        files = [
          ".git-credentials"
        ];
      };
    };
  };
}
