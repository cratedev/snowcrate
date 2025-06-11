{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.chromium;
in {
  options.${namespace}.apps.chromium = with types; {
    enable = mkBoolOpt false "Enable Chromium";
  };

  config = mkIf cfg.enable {
    programs = {
      chromium = {
        enable = true;
      };
    };
  };
}
