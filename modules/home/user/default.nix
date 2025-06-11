{
  lib,
  inputs,
  config,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkDefault;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;

  authorizedKeysLines = lib.splitString "\n" (builtins.readFile "${inputs.nix-ssh}/ssh/authorized_keys");

  default-key =
    lib.findFirst
    (
      line:
        line
        != ""
        && !(lib.hasPrefix "#" line)
        && lib.last (lib.splitString " " (lib.trim line)) == "${cfg.name}@${cfg.hostname}"
    )
    null
    authorizedKeysLines;

  home-directory =
    if cfg.name == null
    then null
    else "/home/${cfg.name}";
in {
  options.${namespace}.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) "${cfg.name}" "The user account name.";
    uid = mkOpt types.int 1001 "UID of the user.";
    fullName = mkOpt types.str "${cfg.fullName}" "The full name of the user.";
    email = mkOpt types.str "${cfg.email}" "The email of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    authorizedKeys = mkOpt types.str default-key "The public key to apply.";
    hostname = mkOpt types.str "default-hostname" "The hostname to use for SSH key selection.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "${namespace}.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "${namespace}.user.home must be set";
      }
      {
        assertion = default-key != null;
        message = "No SSH key found for hostname '${cfg.hostname}' in ${inputs.nix-ssh}/ssh/authorized_keys";
      }
    ];

    home = {
      username = mkDefault cfg.name;
      homeDirectory = mkDefault cfg.home;
    };
  };
}
