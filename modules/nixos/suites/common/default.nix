{
  inputs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.common;
  sharedAuthorizedKeys = builtins.readFile "${inputs.nix-ssh}/ssh/authorized_keys";
in {
  options.${namespace}.suites.common = with types; {
    enable = mkBoolOpt false "Enable Common module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      desktop = {
        niri = enabled;
        hyprland = disabled;
        display-manager = {
          sddm = {
            enable = true;
            wayland = true;
          };
        };
      };

      apps = {
        _1password = enabled;
        managarr = enabled;
      };

      tools = {
        git = enabled;
        ripgrep = enabled;
        cliphist = enabled;
        wlclipboard = enabled;
        nh = enabled;
        impermanence = enabled;
      };

      theming = {
        stylix = enabled;
      };

      hardware = {
        audio = enabled;
        networking = enabled;
      };

      services = {
        openssh = {
          enable = true;
          authorizedKeys = lib.splitString "\n" sharedAuthorizedKeys;
        };
        busybox = enabled;
        fwupd = enabled;
        portals = enabled;
        beszel = enabled;
        gvfs = enabled;
      };

      security = {
        keyring = enabled;
        pam = enabled;
        sudo = enabled;
        agenix = enabled;
      };

      system = {
        boot = enabled;
        fonts = enabled;
        locale = enabled;
        time = enabled;
      };

      nix = enabled;
    };
  };
}
