{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.profiles.desktop = {
    enable = mkBoolOpt false "Enable dev workstation profile";
    display-name = mkOpt str "HDMI-A-1" "Primary display name";
  };

  config = mkIf config.${namespace}.profiles.desktop.enable {
    ${namespace}.profiles.base.enable = true;
  };
}
