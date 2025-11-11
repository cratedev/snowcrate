{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.server;
in {
  options.${namespace}.suites.server = {
    enable = mkEnableOption "Server system configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites.base.enable = true;
    };
  };
}
