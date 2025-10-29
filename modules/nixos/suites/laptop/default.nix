{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.laptop;
in {
  options.${namespace}.suites.laptop = {
    enable = mkEnableOption "Laptop system configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites.common.enable = true;

      tools = {
        virt.enable = true;
      };

      hardware = {
        fingerprint.enable = true;
      };

      services = {
        power.enable = true;
      };
    };
  };
}
