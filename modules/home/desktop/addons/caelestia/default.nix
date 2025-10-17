{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.caelestia;
in {
  options.${namespace}.desktop.addons.caelestia = with types; {
    enable = mkBoolOpt false "Whether to enable caelestia";
  };

  imports = [inputs.caelestia-shell.homeManagerModules.default];
  config = mkIf cfg.enable {
    programs.caelestia = {
      enable = true;
      systemd = {
        enable = false; # if you prefer starting from your compositor
        target = "graphical-session.target";
        environment = [];
      };
      settings = {
        appearance.font.size = {
          scale = 0.75;
        };
        bar.status = {
          showBattery = false;
        };
        paths.wallpaperDir = "/home/matt/snowcrate/assets/wallpaper/";
        services = {
          smartScheme = false;
        };
      };
      cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
          theme.enableGtk = false;
        };
      };
    };
  };
}
