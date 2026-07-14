{...}: {
  flake.modules.nixos.fingerprint = {
    config,
    pkgs,
    lib,
    ...
  }: {
    services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-broadcom;
    };

    environment.persistence."/persist".directories = ["/var/lib/fprint"];

    services.udev.extraRules = ''
      # Fix fprintd USB persist issue for Broadcom fingerprint reader
      # This allows fprintd to manage USB power settings
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0a5c", MODE="0666", TAG+="uaccess"
      # Allow write access to persist file
      SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/persist}="0"
    '';

    security.pam.services = let
      fprintdModule = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
    in {
      login = {
        text = lib.mkForce ''
          auth       sufficient   ${fprintdModule}
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

      # Fingerprint tried first at the greeter, password still works as a
      # fallback at the same prompt if the reader fails. Uses the
      # structured options (not a hand-written `text`) because `text` is
      # `types.lines`, which *concatenates* same-priority mkDefault values
      # instead of replacing them -- a hand-written mkDefault text here
      # would merge with, not replace, NixOS's own auto-generated stack.
      greetd.fprintAuth = true;

      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
    };
  };
}
