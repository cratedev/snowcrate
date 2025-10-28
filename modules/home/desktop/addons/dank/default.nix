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
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  config = mkIf cfg.enable {
    programs.dankMaterialShell = {
      enable = true;
    };
  };
}
