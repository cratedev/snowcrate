{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.laptop;
in {
  options.${namespace}.suites.laptop = with types; {
    enable = mkBoolOpt false "Enable Laptop module";
    display-name = mkOpt str "eDP-1" "Primary display name";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        addons = {
          dank = {enable = false;};
        };
      };
    };
  };
}
