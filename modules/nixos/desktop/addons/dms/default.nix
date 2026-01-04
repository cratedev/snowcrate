{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.dms;
in {
  options.${namespace}.desktop.addons.dms = with types; {
    enable = mkBoolOpt false "Whether or not to enable dms";
  };

  config = mkIf cfg.enable {
    programs.dms-shell = {
      enable = true;
    };
  };
}
