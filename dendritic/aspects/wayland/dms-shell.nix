{inputs, ...}: {
  flake.modules.nixos.dms-shell = {...}: {
    imports = [inputs.dms-plugin-registry.nixosModules.default];

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

    environment.persistence."/persist".users.matt.directories = [
      ".config/DankMaterialShell"
      ".local/state/DankMaterialShell"
    ];
  };
}
