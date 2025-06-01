{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.fzf;
in {
  options.${namespace}.cli.fzf = with types; {
    enable = mkBoolOpt false "Enable/disable fzf";
  };

  config = mkIf cfg.enable {
    programs = {
      fzf = {
        enable = true;
      };
    };
  };
}
