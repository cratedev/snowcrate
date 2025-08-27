{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.managarr;
in {
  options.${namespace}.apps.managarr = with types; {
    enable = mkBoolOpt false "Whether or not to enable managarr";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.managarr];
    home.file.".config/managarr/config.yml".text = ''
        radarr:
      - host: 10.0.0.10
      	port: 7878
      	api_token: 09b8b6d99bfa4bb89a54d55c1e750381
    '';
  };
}
