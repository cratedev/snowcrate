{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.just;
in {
  options.${namespace}.cli.just = with types; {
    enable = mkBoolOpt false "Enable/disable just";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.just];
  };
}
