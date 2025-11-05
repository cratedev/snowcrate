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
    environment.systemPackages = [
      pkgs.polkit_gnome
    ];

    security = {
      polkit.enable = true;
    };

    security.pam.services = {
      sddm.fprintAuth = true;
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
      login.enableGnomeKeyring = lib.mkForce false;
      sddm.enableGnomeKeyring = false;
      sddm-autologin.enableGnomeKeyring = false;
      sudo.enableGnomeKeyring = false;
      polkit-1.enableGnomeKeyring = false;
    };

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
