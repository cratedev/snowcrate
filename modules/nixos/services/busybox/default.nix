{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.busybox;
in {
  options.${namespace}.services.busybox = with types; {
    enable = mkBoolOpt false "Enable busybox;";
  };

  config =
    mkIf cfg.enable {environment.systemPackages = with pkgs; [busybox];};
}
