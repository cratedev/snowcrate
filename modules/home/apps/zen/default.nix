{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.zen;
in {
  options.${namespace}.apps.zen = with types; {
    enable = mkBoolOpt false "Enable zen";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages.x86_64-linux.default
    ];
  };
}
