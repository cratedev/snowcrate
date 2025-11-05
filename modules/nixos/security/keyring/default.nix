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
      seahorse # Optional: GUI to manage keyrings
    ];

    systemd.user.services.gnome-keyring = {
      description = "GNOME Keyring Daemon";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets,ssh";
        Restart = "on-failure";
      };
      environment = {
        XDG_RUNTIME_DIR = "%t";
      };
    };
  };
}
