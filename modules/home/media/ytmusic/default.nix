{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.media.ytmusic;
in {
  options.${namespace}.media.ytmusic = with types; {
    enable = mkBoolOpt false "Enable ytmusic";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ytmdesktop];
  };
}
