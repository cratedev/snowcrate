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
    enable = mkBoolOpt false "Enable Desktop archetype";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        common = enabled;
        desktop = enabled;
      };
    };
  };
}
