{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.managarr;
in {
  options.${namespace}.apps.managarr = with types; {
    enable = mkBoolOpt false "Enable/disable managarr";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.managarr];
  };
}
