{
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.impermanence;
in {
  options.${namespace}.tools.impermanence = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure impermanence.";
  };

  imports = [inputs.impermanence.nixosModules.impermanence];

  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/etc/NetworkManager/system-connections"
        "/var/lib/tailscale"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
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
          "unraid"
          "snowcrate"
          "documents"
          ".steam"
          "games"
          ".config/chromium"
          ".config/vesktop"
          ".config/1Password"
          ".config/obsidian"
          ".config/YouTube Music Desktop App"
          ".config/DankMaterialShell"
          ".local/share/fish"
          ".config/fish"
          ".local/state/nvf/shada" # MRU History
          ".local/state/DankMaterialShell"
          ".local/cache/zellij" # zellij session
          ".zen"
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
          ".config/nushell/history.txt"
        ];
      };
    };
  };
}
