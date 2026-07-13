{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg-user = config.${namespace}.user;

  home-directory =
    if cfg-user.name == null
    then null
    else "/home/${cfg-user.name}";
in {
  config = {
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "zen";
      XDG_CONFIG_HOME = "${home-directory}/.config";
      XDG_DATA_HOME = "${home-directory}/.local/share";
      XDG_BIN_HOME = "${home-directory}/.local/bin";
      XDG_CACHE_HOME = mkDefault "${home-directory}/.cache";
      OP_BIOMETRIC_UNLOCK_ENABLED = "true";
    };
  };
}
