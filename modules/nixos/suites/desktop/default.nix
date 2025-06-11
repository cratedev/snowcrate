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
  options.${namespace}.suites.desktop = with types; {
    enable = mkBoolOpt false "Whether or not to enable desktop configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      tools = {
        #impermanence = enabled; still need to configure btrfs etc
      };

      hardware = {
        #audio = enabled;
        #networking = enabled;
        #fingerprint = enabled;
      };
    };
  };
}
