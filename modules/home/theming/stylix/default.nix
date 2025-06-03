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
      autoEnable = true;
      targets = {
        hyprland.enable = true;
        gtk.enable = true;
      };
    };
  };
}
