{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.archetypes.desktop;
in {
  options.${namespace}.archetypes.desktop = {
    enable = mkEnableOption "desktop home environment";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        niri = {enable = false;};
        hyprland = {enable = true;};
        addons = {
          waybar = {enable = true;};
          gtk = {enable = true;};
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
      };
      cli = {
        nushell = {enable = true;};
        btop = {enable = true;};
        zellij = {enable = true;};
        fzf = {enable = true;};
        just = {enable = true;};
        env = {enable = true;};
      };
      theming = {
        stylix = {enable = true;};
      };
      tools = {
        nvf = {enable = true;};
        git = {enable = true;};
      };
      media = {
        spotify = {enable = true;};
      };
    };
  };
}
