{
  config,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.agenix;
in {
  options.${namespace}.security.agenix = with types; {
    enable = mkBoolOpt false "Whether to enable agenix.";
  };

  config =
    mkIf cfg.enable {
    };
}
