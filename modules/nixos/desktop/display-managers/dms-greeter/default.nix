{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.display-manager.dms-greeter;
  user = config.${namespace}.user.name;
in {
  options.${namespace}.desktop.display-manager.dms-greeter = with types; {
    enable = mkBoolOpt false "Whether or not to enable dms-greeter.";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      dms-greeter = {
        enable = true;
        compositor = {
          name = "niri";
          # DMS's bundled default niri config for the greeter references a
          # `debug { keep-max-bpc-unchanged; }` KDL node that this niri
          # build doesn't recognize, which fails to parse and leaves the
          # greeter's compositor unable to render (see /tmp/dms-greeter.log
          # and `journalctl -b | grep dms-greeter/niri`). Supplying an
          # explicit minimal config avoids that broken default entirely.
          customConfig = ''
            input {
                keyboard {
                    xkb {
                        layout "us"
                    }
                }
            }
          '';
        };
        configHome = "/home/${user}";
        # Save the logs to a file
        logs = {
          save = true;
          path = "/tmp/dms-greeter.log";
        };
      };
    };

    environment.etc."dms-greeter/config.toml".text = ''
      default_user = "${user}"
    '';
  };
}
