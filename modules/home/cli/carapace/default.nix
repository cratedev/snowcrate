{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.carapace;
in {
  options.${namespace}.cli.carapace = with types; {
    enable = mkBoolOpt false "Enable/disable carapace";
  };

  config = mkIf cfg.enable {
    programs.carapace.enable = true;
  };
}
