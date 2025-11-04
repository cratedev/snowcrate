{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.bitwarden;
in {
  options.${namespace}.apps.bitwarden = with types; {
    enable = mkBoolOpt false "Whether or not to enable bitwarden.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [pkgs.bitwarden-desktop pkgs.bitwarden-cli];
    };
  };
}
