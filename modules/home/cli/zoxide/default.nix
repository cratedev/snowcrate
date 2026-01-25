{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.zoxide;
in {
  options.${namespace}.cli.zoxide = with types; {
    enable = mkBoolOpt false "Enable/disable zoxide";
  };

  config = mkIf cfg.enable {
    programs = {
      zoxide = {
        enable = true;
        options = ["--cmd" "cd"];
      };
    };
  };
}
