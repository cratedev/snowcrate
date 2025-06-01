{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.firefox;
in {
  options.${namespace}.apps.firefox = with types; {
    enable = mkBoolOpt false "Enable Firefox";
  };

  config = mkIf cfg.enable {
    programs = {
      firefox = {
        enable = true;
        profiles = {
          matt = {};
        };
      };
    };
  };
}
