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
      # This helps ensure PAM modules are properly available
      pam.enableFscrypt = false;
    };

    security.pam.services = {
      # Only enable fingerprint auth where it makes sense
      # Remove sddm if you don't use it
      login.fprintAuth = lib.mkIf config.${namespace}.hardware.fingerprint.enable true;
      sudo.fprintAuth = lib.mkIf config.${namespace}.hardware.fingerprint.enable true;
      polkit-1.fprintAuth = lib.mkIf config.${namespace}.hardware.fingerprint.enable true;

      # Completely disable gnome keyring in PAM since you're managing it separately
      login.enableGnomeKeyring = lib.mkForce false;
      sddm.enableGnomeKeyring = lib.mkForce false;
      sddm-autologin.enableGnomeKeyring = lib.mkForce false;
      sudo.enableGnomeKeyring = lib.mkForce false;
      polkit-1.enableGnomeKeyring = lib.mkForce false;
    };
    # Create symlink for pam_fprintd.so in the PAM security directory
    system.activationScripts.fixPamFprintd = lib.stringAfter ["users"] ''
      ln -sf ${pkgs.fprintd}/lib/security/pam_fprintd.so \
             /run/current-system/sw/lib/security/pam_fprintd.so 2>/dev/null || true
    '';

    # Ensure the directory exists
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
