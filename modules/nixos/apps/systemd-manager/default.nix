{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.systemd-manager;
in {
  options.${namespace}.apps.systemd-manager = with types; {
    enable = mkBoolOpt false "Whether or not to enable systemd-manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      systemd-tui-manager
    ];
  };
}
