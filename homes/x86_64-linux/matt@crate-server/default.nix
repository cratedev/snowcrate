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
  };

  config = mkIf config.${namespace}.profiles.server.enable {
    ${namespace}.profiles.server.enable = true;
  };

  home.stateVersion = "24.05";
}
