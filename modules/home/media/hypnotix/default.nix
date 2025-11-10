{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.media.hypnotix;
in {
  options.${namespace}.media.hypnotix = with types; {
    enable = mkBoolOpt false "Enable hypnotix";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [hypnotix];
  };
}
