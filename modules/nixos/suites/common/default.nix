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
  knownhosts = builtins.readFile "${inputs.nix-ssh}/ssh/knownHosts";
in {
  options.${namespace}.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      nix = {enable = true;};

      desktop = {
        niri = enabled;
        display-manager = {
          sddm = {
            enable = true;
            wayland = true;
          };
        };
      };

      apps = {
        rofi = enabled;
        _1password = enabled;
      };

      tools = {
        git = enabled;
        ripgrep = enabled;
        cliphist = enabled;
        wlclipboard = enabled;
        nh = enabled;
      };

      theming = {
        stylix = enabled;
      };

      hardware = {
        #audio = enabled;
        networking = enabled;
      };

      services = {
        openssh = {
          enable = true;
          authorizedKeys = lib.splitString "\n" sharedAuthorizedKeys;
          knownHosts = knownhosts;
        };
        busybox = {
          enable = true;
        };
        fwupd = enabled;
      };

      security = {
        keyring = enabled;
        pam = enabled;
        sudo = enabled;
      };

      system = {
        boot = enabled;
        fonts = enabled;
        locale = enabled;
        time = enabled;
        #xkb = enabled;
      };
    };
  };
}
