{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.base;
in {
  options.${namespace}.suites.base = {
    enable = mkEnableOption "Desktop system configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        niri.enable = true;
        display-manager = {
          sddm = {
            enable = false;
            wayland = true;
          };
          dms-greeter.enable = true;
        };
      };
      apps = {
        _1password.enable = true;
        managarr.enable = true;
      };
      tools = {
        git.enable = true;
        ripgrep.enable = true;
        cliphist.enable = true;
        wlclipboard.enable = true;
        nh.enable = true;
        impermanence.enable = true;
      };
      theming = {
        stylix.enable = true;
      };
      hardware = {
        audio.enable = true;
        networking.enable = true;
      };
      services = {
        openssh.enable = true;
        busybox.enable = true;
        fwupd.enable = true;
        portals.enable = true;
        beszel.enable = true;
        gvfs.enable = true;
        tailscale.enable = true;
      };
      security = {
        pam.enable = true;
        sudo.enable = true;
        agenix.enable = true;
      };
      system = {
        boot.enable = true;
        fonts.enable = true;
        locale.enable = true;
        time.enable = true;
      };
      nix.enable = true;
    };
  };
}
