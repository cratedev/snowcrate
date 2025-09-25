{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.suites.laptop;
in {
  options.${namespace}.suites.laptop = with types; {
    enable = mkBoolOpt false "Whether or not to enable laptop configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    services = {
      power-profiles-daemon.enable = false;
      thermald.enable = false;
      tlp.enable = false;

      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };
    };

    ${namespace} = {
      tools = {
        impermanence = enabled;
        virt = enabled;
      };

      hardware = {
        fingerprint = enabled;
      };
    };
  };
}
