{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.theming.stylix;
  stylixTheme = "da-one-ocean"; #darkmoss ayu-mirage da-one-gray horizon-dark tokyo-city-terminal-dark
in {
  options.${namespace}.theming.stylix = with types; {
    enable = mkBoolOpt false "Whether or not to enable stylix.";
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";
      fonts.sizes = {applications = 10;};
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${stylixTheme}.yaml";
    };
  };
}
