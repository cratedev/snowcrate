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
      gnome-keyring
      libsecret
      seahorse
    ];

    services.gnome.gnome-keyring.enable = true;

    security = {
      polkit.enable = true;

      pam.services = {
        login.fprintAuth = true;

        greetd = {
          fprintAuth = true;
          text = mkDefault ''
            auth       sufficient   pam_fprintd.so
            auth       include      login

            account    include      login
            password   include      login
            session    include      login
          '';
        };

        login = {
          text = mkForce ''
            auth       sufficient   pam_fprintd.so
            auth       required     pam_unix.so try_first_pass nullok
            auth       optional     pam_permit.so

            account    required     pam_unix.so

            password   include     pam_unix.so nullok shadow

            session    required     pam_env.so conffile=/etc/pam/environment readenv=0
            session    required     pam_unix.so
            session    required     pam_loginuid.so
            session    optional     ${pkgs.systemd}/lib/security/pam_systemd.so
          '';
        };

        sudo.fprintAuth = true;
        polkit-1.fprintAuth = true;
      };
    };
  };
}
