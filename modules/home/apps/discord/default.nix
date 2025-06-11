{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.discord;
in {
  options.${namespace}.apps.discord = with types; {
    enable = mkBoolOpt false "Whether or not to enable discord.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.vesktop];
  };
}
