{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.archetypes.laptop;
in {
  options.${namespace}.archetypes.laptop = with types; {
    enable = mkEnableOption "laptop home environment";
    display-name = mkOpt str "eDP-1" "The name of the primary display";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        #niri = {enable = true;};
        hyprland = {enable = true;};
        addons = {
          #waybar = {enable = true;};
          gtk = {enable = true;};
          mako = {enable = true;};
          hyprlock = {enable = true;};
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

      media = {
        ytmusic = enabled;
        spotify = enabled;
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
    };
  };
}
