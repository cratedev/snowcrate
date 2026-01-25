{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = {
    enable = mkEnableOption "Desktop system configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites = {
        base.enable = true;
        gaming.enable = true;
      };
    };
  };
}
