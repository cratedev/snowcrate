{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.wlsunset;
in {
  options.${namespace}.tools.wlsunset = with types; {
    enable = mkBoolOpt false "Enable wlsunset";
  };

  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = 45.3;
      longitude = -75.6;
      temperature = {
        night = 5000;
      };
    };
  };
}
