{
  lib,
  config,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkDefault;
  inherit (lib.${namespace}) mkOpt;
  cfg = config.${namespace}.user;
in {
  options.${namespace}.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    name = mkOpt types.str "matt" "The user account name.";
    fullName = mkOpt types.str "Matthew Henderson" "The full name of the user.";
    email = mkOpt types.str "matt@crate.dev" "The email of the user.";
  };

  config = mkIf cfg.enable {
    home = {
      username = mkDefault cfg.name;
      homeDirectory = mkDefault "/home/${cfg.name}";
    };
  };
}
