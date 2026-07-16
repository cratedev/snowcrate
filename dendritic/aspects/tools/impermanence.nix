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

      # SSH host keys persist via services.openssh.hostKeys (openssh.nix).
      files = [
        "/etc/machine-id"
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
