{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.rofi;
in {
  options.${namespace}.apps.rofi = with types; {
    enable = mkBoolOpt false "Whether or not to enable rofi";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.rofi-wayland];
    crate.home.configFile."rofi".source = ./rofi;
  };
}
