{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = {
    enable = mkEnableOption "Desktop system configuration";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      suites.base.enable = true;

      apps = {
        steam.enable = true;
      };
    };
    programs.xwayland.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
