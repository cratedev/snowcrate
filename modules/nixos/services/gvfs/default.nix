{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.gvfs;
in {
  options.${namespace}.services.gvfs = with types; {
    enable = mkBoolOpt false "Whether to enable gvfs";
  };

  config = mkIf cfg.enable {
    services.gvfs.enable = true;
  };
}
