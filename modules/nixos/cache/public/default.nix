{
  config,
  lib,
  namespace,
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
      "https://nix-community.cachix.org".key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      "https://hyprland.cachix.org".key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    };
  };
}
