{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.ghostty;
in {
  options.${namespace}.apps.ghostty = with types; {
    enable = mkBoolOpt false "Enable/disable ghostty";
  };

  config = mkIf cfg.enable {
    programs = {
      ghostty = {
        enable = true;
        settings = {
          gtk-tabs-location = "hidden";
          font-size = "10";
          scrollback-limit = "10_000";
          clipboard-read = "allow";
          clipboard-paste-protection = "false";
          window-decoration = "false";
          window-padding-x = "6";
          window-padding-y = "6";
          window-padding-balance = "true";
          shell-integration = "detect";
          confirm-close-surface = "false";
        };
      };
    };
  };
}
