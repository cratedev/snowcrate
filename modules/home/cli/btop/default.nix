{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.btop;
in {
  options.${namespace}.cli.btop = with types; {
    enable = mkBoolOpt false "Enable/disable btop";
  };

  config = mkIf cfg.enable {
    programs = {
      btop = {
        enable = true;
      };
    };
  };
}
