{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = {
    enable = mkBoolOpt false "Enable Desktop module";
    display-name = mkOpt str "HDMI-A-1" "Primary display name";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      apps = {
      };
    };
  };
}
