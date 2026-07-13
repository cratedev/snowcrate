{...}: {
  flake.modules.nixos.dms-greeter = {...}: {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "niri";
        # DMS's own bundled default niri config for the greeter references a
        # `debug { keep-max-bpc-unchanged; }` KDL node that the pinned niri
        # build here doesn't recognize, which fails to parse and leaves the
        # greeter's compositor unable to render. An explicit minimal config
        # avoids that broken default entirely.
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
      configHome = "/home/matt";
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };

    environment.etc."dms-greeter/config.toml".text = ''
      default_user = "matt"
    '';
  };
}
