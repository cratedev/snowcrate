{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.fwupd;
in {
  options.${namespace}.services.fwupd = with types; {
    enable = mkBoolOpt false "Whether or not to enable common fwupd.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.fwupd];
    services.fwupd.enable = true;
  };
}
