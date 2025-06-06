{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.mako;
in {
  options.${namespace}.desktop.addons.mako = with types; {
    enable = mkBoolOpt false "Whether to enable mako";
  };
  config = mkIf cfg.enable {
    programs.mako = {
      enable = true;
      settings = {
        actions = true;
        anchor = "top-right";
        background-color = "#000000";
        border-color = "#FFFFFF";
        border-radius = 0;
        default-timeout = 0;
        font = "monospace 10";
        height = 100;
        width = 300;
        icons = true;
        ignore-timeout = false;
        layer = "top";
        margin = 10;
        markup = true;

        # Section example
        "actionable=true" = {
          anchor = "top-left";
        };
      };
    };
  };
}
