{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.managarr;
in {
  options.${namespace}.cli.managarr = with types; {
    enable = mkBoolOpt false "Enable/disable managarr";
  };

  config = mkIf cfg.enable {
    home.file.".config/managarr/config.yml".text = ''
      radarr:
      - host: 10.0.0.10
        port: 7878
        api_token: 09b8b6d99bfa4bb89a54d55c1e750381
      sonarr:
      - host: 10.0.0.10
        port: 8989
        api_token: 49518ebb0488401d9f5a9d675ee8dc37
    '';
  };
}
