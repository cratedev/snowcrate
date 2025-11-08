{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.fingerprint;
in {
  options.${namespace}.hardware.fingerprint = with types; {
    enable = mkBoolOpt false "Whether or not to enable fingerprint support.";
  };
  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-broadcom;
    };

    # Add udev rules to fix the USB persist issue
    services.udev.extraRules = ''
      # Fix fprintd USB persist issue for Broadcom fingerprint reader
      # This allows fprintd to manage USB power settings
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0a5c", MODE="0666", TAG+="uaccess"
      # Allow write access to persist file
      SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/persist}="0"
    '';
  };
}
