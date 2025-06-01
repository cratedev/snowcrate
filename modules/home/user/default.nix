{
  lib,
  inputs,
  config,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;

  # Use the hostname from config.crate.user.hostname
  hostname = config.crate.user.hostname;

  # Read the authorized_keys file from inputs.nix-ssh
  authorizedKeysFile = "${inputs.nix-ssh}/ssh/authorized_keys";

  # Parse the authorized_keys file into a list of lines
  authorizedKeysLines = lib.splitString "\n" (builtins.readFile authorizedKeysFile);

  # Filter out empty lines and comments, then find the key matching the hostname
  default-key =
    lib.findFirst
    (
      line: let
        parts = lib.splitString " " (lib.trim line);
        comment =
          if (builtins.length parts) > 2
          then lib.last parts
          else "";
      in
        line != "" && !(lib.hasPrefix "#" line) && comment == "matt@${hostname}"
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
    name = mkOpt (types.nullOr types.str) config.crate.user.name "The user account name.";
    uid = mkOpt types.int 1001 "UID of the user.";
    fullName = mkOpt types.str "Matthew Henderson" "The full name of the user.";
    email = mkOpt types.str "matt@crate.dev" "The email of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    authorizedKeys = mkOpt types.str default-key "The public key to apply.";
    hostname = mkOpt types.str "default-hostname" "The hostname to use for SSH key selection.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
          message = "No SSH key found for hostname '${hostname}' in ${authorizedKeysFile}";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;
      };
    }
  ]);
}
