{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.dank;
in {
  options.${namespace}.desktop.addons.dank = with types; {
    enable = mkBoolOpt false "Whether to enable dank";
  };

  imports = [
    inputs.dankMaterialShell.homeModules.dank-material-shell
    inputs.dankMaterialShell.homeModules.niri
  ];

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
    };
  };
}
