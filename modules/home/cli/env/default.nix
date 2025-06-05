{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg-user = config.${namespace}.user;

  # aliases = import ./aliases.nix { inherit pkgs; };
  home-directory =
    if cfg-user.name == null
    then null
    else "/home/${cfg-user.name}";
in {
  options.${namespace}.cli.env = with types;
    mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (_n: v:
        if isList v
        then concatMapStringsSep ":" (x: toString x) v
        else (toString v));
      default = {};
      description = "A set of environment variables to set.";
    };

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
      #NH_FLAKE = "${home-directory}/snow${namespace}";
    };
  };
}
