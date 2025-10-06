{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.fish;
in {
  options.${namespace}.cli.fish = with types; {
    enable = mkBoolOpt false "Enable/disable fish";
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
      };
    };
  };
}
