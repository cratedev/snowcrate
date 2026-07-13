{...}: {
  flake.modules.nixos.fingerprint = {pkgs, ...}: {
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
  };
}
