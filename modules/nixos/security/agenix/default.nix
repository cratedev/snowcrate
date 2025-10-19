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

  imports = [inputs.agenix.nixosModules.default];

  config = mkIf cfg.enable {
    environment.systemPackages = [inputs.agenix.packages.x86_64-linux.default];
  };
}
