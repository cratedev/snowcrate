{...}: {
  flake.modules.nixos.fingerprint = {
    pkgs,
    lib,
    ...
  }: {
    services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-broadcom;
    };

    services.udev.extraRules = ''
      # Fix fprintd USB persist issue for Broadcom fingerprint reader
      # This allows fprintd to manage USB power settings
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0a5c", MODE="0666", TAG+="uaccess"
      # Allow write access to persist file
      SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/persist}="0"
    '';

    security.pam.services = {
      login = {
        fprintAuth = true;
        text = lib.mkForce ''
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

      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
    };
  };
}
