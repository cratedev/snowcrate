{...}: {
  flake.modules.nixos.dms-greeter = {...}: {
    # Enabling both programs.niri and programs.uwsm.waylandCompositors.niri
    # registers two session entries ("niri" direct, "niri-uwsm" managed) --
    # nixpkgs' uwsm module doesn't expose a way to suppress the plain one,
    # so this defaults the greeter to the uwsm-managed session rather than
    # leaving it to chance which one gets picked.
    services.displayManager.defaultSession = "niri-uwsm";

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

          hotkey-overlay {
              skip-at-startup
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
