{...}: {
  flake.modules.nixos.pam = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [
      pkgs.gnome-keyring
      pkgs.libsecret
      pkgs.seahorse
    ];

    services.gnome.gnome-keyring.enable = true;

    security = {
      polkit.enable = true;

      # mkDefault: overridden by mkForce on hosts with a fingerprint
      # reader (hardware/fingerprint.nix).
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
