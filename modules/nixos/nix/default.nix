{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.nix;
in {
  options.${namespace}.nix = with types; {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-index
      nix-prefetch-scripts
    ];
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        http-connections = 50;
        connect-timeout = 5;
        warn-dirty = false;
        log-lines = 50;
        max-jobs = "auto";
        max-substitution-jobs = "128";
        cores = 0;
        eval-cores = 0;
        keep-outputs = true;
        builders-use-substitutes = true;
        auto-optimise-store = true;
        substituters = [
          "https://notashelf.cachix.org"
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://niri.cachix.org"
        ];
        trusted-public-keys = [
          "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2VHAW2aH7iuDQfFh1OqFn5shZc="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];
      };

      gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };
  };
}
