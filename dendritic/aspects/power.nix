{...}: {
  flake.modules.nixos.power = {...}: {
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
