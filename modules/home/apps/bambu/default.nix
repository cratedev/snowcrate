{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.bambu;
in {
  options.${namespace}.apps.bambu = with types; {
    enable = mkBoolOpt false "Enable Bambu Studio";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.bambu-studio
    ];
  };
}
