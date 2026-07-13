{...}: {
  flake.modules.nixos.dms-greeter = {...}: {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "niri";
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
