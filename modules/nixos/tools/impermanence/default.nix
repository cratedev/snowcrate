{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.impermanence;
  #  inherit (cfg) user;
in {
  options.${namespace}.tools.impermanence = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure impermanence.";
  };

  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/tailscale"
        "/var/log"
        "/var/lib/NetworkManager"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/etc/ssh"
        "/etc/NetworkManager"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];

      files = ["/etc/machine-id"];

      users.matt = {
        directories = [
          "whiskeyvault"
          "unraid"
          "snowcrate"
          "documents"
          ".config/chromium"
          ".config/vesktop"
          ".config/spotify"
          ".config/1Password"
          ".config/YouTube Music Desktop App"
          ".local/share/keyrings"
          ".local/state/nvf/shada" # MRU History
          ".cache/zellij" # zellij session
          ".zen"
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".gnupg";
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
