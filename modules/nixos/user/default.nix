{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.user;
in {
  options.${namespace}.user = with types; {
    name = mkOpt str "matt" "The name to use for the user account.";
    fullName = mkOpt str "Matthew Henderson" "The full name of the user.";
    email = mkOpt str "matt@crate.dev" "The email of the user.";
    hashedPassword =
      mkOpt (nullOr str) null
      "The hashed password for the user account.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs {} (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {
    crate.home = {
      file = {
        "images/screenshots/.keep".text = "";
      };
    };

    users.users.${cfg.name} =
      {
        isNormalUser = true;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.nushell;

        # Arbitrary user ID to use for the user. Since I only
        # have a single user on my machines this won't ever collide.
        # However, if you add multiple users you'll need to change this
        # so each user has their own unique uid (or leave it out for the
        # system to select).
        uid = 1001;

        extraGroups = ["steamcmd"] ++ cfg.extraGroups;
      }
      // optionalAttrs (cfg.hashedPassword != null) {
        inherit (cfg) name hashedPassword;
      }
      // cfg.extraOptions;
  };
}
