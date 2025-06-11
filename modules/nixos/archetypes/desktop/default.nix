{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.archetypes.desktop;
in {
  options.${namespace}.archetypes.desktop = with types; {
    enable = mkBoolOpt false "enable/disable the desktop archetype";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        common = enabled;
        desktop = enabled;
      };
      services = {
        #ntp = enabled;
      };
      system = {
        #wifi = {
        #  enable = true;
        #  networks = {
        #    SkyNet = { ssid = "SkyNet"; };
        #  };
        #};
      };
    };
  };
}
