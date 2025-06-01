{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.niri;
in {
  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable niri.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
    ];
    programs.niri.enable = true;
  };
}
