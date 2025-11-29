{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.nix-index;
in {
  options.${namespace}.cli.nix-index = with types; {
    enable = mkBoolOpt false "Enable/disable nix-index";
  };

  config = mkIf cfg.enable {
    programs = {
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      command-not-found.enable = false;
    };
  };
}
