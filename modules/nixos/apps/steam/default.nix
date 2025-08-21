{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.steam;
in {
  options.${namespace}.apps.steam = with types; {
    enable = mkBoolOpt false "Whether or not to enable steam";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
