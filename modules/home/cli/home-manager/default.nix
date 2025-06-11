{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.home-manager;
in {
  options.${namespace}.cli.home-manager = with types; {
    enable = mkBoolOpt false "Enable/disable home-manager";
  };

  config = mkIf cfg.enable {
    programs = {
      home-manager = {
        enable = true;
      };
    };
  };
}
