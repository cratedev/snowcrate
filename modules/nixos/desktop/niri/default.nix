{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.niri;
in {
  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable niri.";
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;
    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        niri = {
          prettyName = "niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };
    };
  };
}
