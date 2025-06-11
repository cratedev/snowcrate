{
  config,
  inputs,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.media.spotify;
in {
  options.${namespace}.media.spotify = with types; {
    enable = mkBoolOpt false "Enable spotify";
  };

  imports = [inputs.spicetify-nix.homeManagerModules.default];
  config = mkIf cfg.enable {
    programs = {
      ncspot.enable = true;
      spicetify = {
        enable = true;
        enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.system}.extensions; [
          adblock
          hidePodcasts
          shuffle
        ];
        theme = lib.mkForce inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
        colorScheme = lib.mkForce "mocha";
      };
    };
  };
}
