{
  config,
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.quickshell;
in {
  options.${namespace}.apps.quickshell = with types; {
    enable = mkBoolOpt false "Whether or not to enable quickshell";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.quickshell.packages.x86_64-linux.default
      jq
      fish
      fd
      cava
      ddcutil
      brightnessctl
      curl
      cava
      python313Packages.aubio
      python313Packages.pyaudio
      python313Packages.materialyoucolor
      imagemagick
      matugen
    ];
    crate.home.configFile."quickshell/caelestia".source = ./caelestia;
  };
}
