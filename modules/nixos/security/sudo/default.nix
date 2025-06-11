{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.sudo;
in {
  options.${namespace}.security.sudo = with types; {
    enable = mkBoolOpt false "Enable/disable sudo.";
  };

  config = mkIf cfg.enable {
    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults lecture = never
      '';
    };
  };
}
