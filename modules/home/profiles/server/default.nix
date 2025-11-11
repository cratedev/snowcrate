{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.profiles.server = {
    enable = mkBoolOpt false "Enable server profile";
    display-name = mkOpt str "HDMI-A-1" "Primary display name";
  };

  config = mkIf config.${namespace}.profiles.server.enable {
    ${namespace}.profiles.base.enable = true;
  };
}
