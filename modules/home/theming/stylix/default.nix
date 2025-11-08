{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.theming.stylix;
in {
  options.${namespace}.theming.stylix = with types; {
    enable = mkBoolOpt false "Enable stylix targets";
  };

  config = mkIf cfg.enable {
    stylix = {
      autoEnable = false;
      targets = {
        firefox = {
          enable = true;
          profileNames = ["matt"];
        };
        ghostty.enable = true;
        btop.enable = true;
        fzf.enable = true;
        gtk.enable = true;
        niri.enable = true;
        zellij.enable = true;
        nvf.enable = true;
      };
    };
  };
}
