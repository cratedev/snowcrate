{
  lib,
  config,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.power;
in {
  options.${namespace}.services.power = with types; {
    enable = mkBoolOpt false "Enable Power module";
  };

  config = mkIf cfg.enable {
    services = {
      power-profiles-daemon.enable = false;
      thermald.enable = false;
      tlp.enable = false;
      upower.enable = true;

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
  };
}
