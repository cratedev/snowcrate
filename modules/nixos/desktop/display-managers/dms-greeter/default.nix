{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.display-manager.dms-greeter;
  user = config.${namespace}.user.name;
in {
  options.${namespace}.desktop.display-manager.dms-greeter = with types; {
    enable = mkBoolOpt false "Whether or not to enable dms-greeter.";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      dms-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/${user}";
      };
    };

    environment.etc."dms-greeter/config.toml".text = ''
      default_user = "${user}"
    '';
  };
}
