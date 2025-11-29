{
  config,
  lib,
  pkgs,
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
    programs.nix-index-database.comma.enable = true;
    programs.command-not-found.enable = false;
  };
}
