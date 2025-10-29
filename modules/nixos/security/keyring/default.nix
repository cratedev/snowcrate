{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.keyring;
in {
  options.${namespace}.security.keyring = with types; {
    enable = mkBoolOpt false "Whether to enable gnome keyring.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-keyring
      seahorse # GUI for managing keyrings (optional but helpful)
    ];
    services.gnome.gnome-keyring.enable = true;
    security.pam.services = {
      login.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
      sudo.enableGnomeKeyring = true; # Also enable for sudo
      polkit-1.enableGnomeKeyring = true; # And polkit
    };
  };
}
