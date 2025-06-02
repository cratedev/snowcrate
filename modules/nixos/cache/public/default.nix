{
  config,
  lib,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cache.public;
in {
  options.${namespace}.cache.public = {
    enable = mkEnableOption "NixOS public cache";
  };
  config = mkIf cfg.enable {
    ${namespace}.nix.extra-substituters = {
      "https://cache.nixos.org/".key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    };
  };
}
