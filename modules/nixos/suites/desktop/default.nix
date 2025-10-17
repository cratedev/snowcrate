{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = with types; {
    enable = mkBoolOpt false "Enable Desktop module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      tools = {
        impermanence = enabled;
      };

      apps = {
        steam = enabled;
      };
    };
  };
}
