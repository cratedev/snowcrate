{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.pam;
in {
  options.${namespace}.security.pam = with types; {
    enable = mkBoolOpt false "Whether to enable pam.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      polkit_gnome
      gnome-keyring # Needed for keyring support
      libsecret # Provides secret-tool command
      seahorse # GUI to manage keyrings
    ];
    services.gnome.gnome-keyring.enable = true;
    security = {
      polkit.enable = true;
    };
    environment.pathsToLink = ["/lib/security"];

    # Polkit agent service
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
