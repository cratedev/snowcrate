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
    enable = mkBoolOpt false "Whether or not to enable laptop configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    services = {
      #logind.lidSwitch = "ignore";
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
      };

      hardware = {
        #audio = enabled;
        #networking = enabled;
        fingerprint = enabled;
      };
    };
  };
}
