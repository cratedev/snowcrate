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
  options.${namespace}.suites.laptop = with types; {
    enable = mkBoolOpt false "Enable Laptop module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      tools = {
        virt = enabled;
      };

      hardware = {
        fingerprint = enabled;
      };

      services = {
        power = enabled;
      };
    };
  };
}
