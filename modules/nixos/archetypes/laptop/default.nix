{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.archetypes.laptop;
in {
  options.${namespace}.archetypes.laptop = with types; {
    enable = mkBoolOpt false "enable/disable the laptop archetype";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        common = enabled;
        laptop = enabled;
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
