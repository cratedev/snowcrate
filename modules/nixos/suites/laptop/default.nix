{
  config,
  lib,
  namespace,
  pkgs,
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
      suites.base.enable = true;

      hardware.fingerprint.enable = true;

      services.power.enable = true;
    };
    programs.xwayland.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
