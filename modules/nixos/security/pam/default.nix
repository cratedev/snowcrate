{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.pam;
in {
  options.${namespace}.security.pam = with types; {
    enable = mkBoolOpt false "Whether to enable pam.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kdePackages.polkit-qt-1
    ];
    security = {
      polkit.enable = true;

      pam.services.sddm.text = ''
        auth      sufficient   pam_fprintd.so
        auth      required     pam_unix.so try_first_pass
        account   required     pam_unix.so
        session   required     pam_unix.so
      '';
    };
  };
}
