{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.keyring;
in {
  options.${namespace}.security.keyring = with types; {
    enable = mkBoolOpt false "Whether to enable gnome keyring.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-keyring
      seahorse # Optional: GUI to manage keyrings
    ];

    # Ensure the systemd user service is properly configured
    systemd.user.services.gnome-keyring = {
      description = "GNOME Keyring Daemon";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      before = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh";
        Restart = "on-failure";
        # Ensure the runtime directory exists
        RuntimeDirectory = "keyring";
        RuntimeDirectoryMode = "0700";
      };
      environment = {
        XDG_RUNTIME_DIR = "%t";
      };
    };

    # Set environment variables for keyring integration
    environment.sessionVariables = {
      GNOME_KEYRING_CONTROL = "\${XDG_RUNTIME_DIR}/keyring";
    };
  };
}
