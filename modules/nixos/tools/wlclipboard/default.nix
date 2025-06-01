{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.wlclipboard;
in {
  options.${namespace}.tools.wlclipboard = with types; {
    enable = mkBoolOpt false "Whether or not to enable wlclipboard.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
