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

      # SSH host key persistence is handled directly by
      # services.openssh.hostKeys pointing at /persist/etc/ssh/... paths
      # (see openssh.nix), not via bind-mounting the conventional
      # /etc/ssh/... paths -- so no host-key entries belong here.
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
