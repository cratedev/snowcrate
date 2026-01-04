{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.beszel;
in {
  options.${namespace}.services.beszel = with types; {
    enable = mkBoolOpt false "Enable beszel;";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [beszel];
    services.beszel.agent = {
      enable = true;
      environmentFile = config.age.secrets.beszel-env.path;
    };
  };
}
