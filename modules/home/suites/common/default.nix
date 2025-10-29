{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.common;
in {
  options.${namespace}.suites.common = with types; {
    enable = mkBoolOpt false "Enable Common module";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        niri = {enable = true;};
        hyprland = {enable = false;};

        addons = {
          gtk = {enable = true;};
          mako = {enable = false;};
          hyprlock = {enable = false;};
          dank = {enable = true;};
        };
      };

      user = {
        enable = true;
      };

      xdg = {
        enable = true;
      };

      apps = {
        firefox = {enable = true;};
        ghostty = {enable = true;};
        zen = {enable = true;};
        obsidian = {enable = true;};
        discord = {enable = true;};
        nautilus = {enable = true;};
        orca = {enable = true;};
      };

      media = {
        ytmusic = {enable = true;};
        spotify = {enable = false;};
      };

      cli = {
        nushell = {enable = true;};
        fish = {enable = true;};
        btop = {enable = true;};
        zellij = {enable = true;};
        fzf = {enable = true;};
        just = {enable = true;};
        env = {enable = true;};
        managarr = {enable = true;};
      };

      theming = {
        stylix = {enable = true;};
      };

      tools = {
        nvf = {enable = true;};
        git = {enable = true;};
        wlsunset = {enable = true;};
      };
    };
  };
}
