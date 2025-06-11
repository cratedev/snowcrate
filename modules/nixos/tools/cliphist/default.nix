{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.cliphist;
in {
  options.${namespace}.tools.cliphist = with types; {
    enable = mkBoolOpt false "Whether or not to enable cliphist.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cliphist
    ];
  };
}
