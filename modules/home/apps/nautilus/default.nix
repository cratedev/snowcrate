{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.nautilus;
in {
  options.${namespace}.apps.nautilus = with types; {
    enable = mkBoolOpt false "Enable/disable nautilus";
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.nautilus];
  };
}
