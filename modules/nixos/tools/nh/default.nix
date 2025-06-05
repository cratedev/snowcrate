{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.nh;
  #cfg-user = config.${namespace}.user.name;
in {
  options.${namespace}.tools.nh = with types; {
    enable = mkBoolOpt false "Whether or not to enable common nh.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.nh];
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      #flake = "/home/${cfg-user}/snowcrate";
    };
  };
}
