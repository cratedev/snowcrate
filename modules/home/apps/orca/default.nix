{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.orca;
in {
  options.${namespace}.apps.orca = with types; {
    enable = mkBoolOpt false "Enable Orca Slicer";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.orca-slicer
    ];
  };
}
