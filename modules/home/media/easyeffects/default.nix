{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.media.easyeffects;
in {
  options.${namespace}.media.easyeffects = with types; {
    enable = mkBoolOpt false "Enable easyeffects";
  };

  config = mkIf cfg.enable {
    services.easyeffects.enable = true;
  };
}
