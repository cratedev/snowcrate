{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.fingerprint;
in {
  options.${namespace}.hardware.fingerprint = with types; {
    enable = mkBoolOpt false "Whether or not to enable fingerprint support.";
  };

  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-broadcom;
    };
  };
}
