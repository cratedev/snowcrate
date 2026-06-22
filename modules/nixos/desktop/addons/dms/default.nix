{
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.dms;
in {
  options.${namespace}.desktop.addons.dms = with types; {
    enable = mkBoolOpt false "Whether or not to enable dms";
  };

  imports = [inputs.dms-plugin-registry.nixosModules.default];

  config = mkIf cfg.enable {
    programs.dms-shell = {
      enable = true;
      plugins = {
        dankBatteryAlerts.enable = true;
        dankClight.enable = true;
        webSearch.enable = true;
        dankLauncherKeys.enable = true;
        nixMonitor.enable = true;
      };
    };
  };
}
