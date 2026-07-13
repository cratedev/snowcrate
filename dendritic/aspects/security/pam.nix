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

      # Plain password-only login stack. Hosts with a fingerprint reader
      # (hardware/fingerprint.nix) override this with mkForce to add
      # pam_fprintd.so -- mkDefault here lets that happen cleanly without
      # a conflicting-definitions error on hosts that don't.
      pam.services.login.text = lib.mkDefault ''
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
  };
}
