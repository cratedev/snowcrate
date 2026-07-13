{...}: {
  flake.modules.nixos.pam = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [
      pkgs.polkit_gnome
      pkgs.gnome-keyring
      pkgs.libsecret
      pkgs.seahorse
    ];

    services.gnome.gnome-keyring.enable = true;

    security = {
      polkit.enable = true;

      pam.services = {
        login.fprintAuth = true;

        greetd = {
          fprintAuth = true;
          text = lib.mkDefault ''
            auth       sufficient   pam_fprintd.so
            auth       include      login

            account    include      login
            password   include      login
            session    include      login
          '';
        };

        login.text = lib.mkForce ''
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

        sudo.fprintAuth = true;
        polkit-1.fprintAuth = true;
      };
    };
  };
}
