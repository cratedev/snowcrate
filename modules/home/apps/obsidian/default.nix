{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.obsidian;
in {
  options.${namespace}.apps.obsidian = with types; {
    enable = mkBoolOpt false "Enable/disable Obsidian";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.obsidian];
  };
}
