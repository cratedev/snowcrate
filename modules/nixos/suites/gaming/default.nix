{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.gaming;
in {
  options.${namespace}.suites.gaming = {
    enable = mkEnableOption "Gaming configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      apps.steam.enable = true;
    };
  };
}
