{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.signal;
in {
  options.${namespace}.apps.signal = with types; {
    enable = mkBoolOpt false "Whether or not to enable aignal";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.signal-desktop];
  };
}
