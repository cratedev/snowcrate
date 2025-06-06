{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps._1password;
in {
  options.${namespace}.apps._1password = with types; {
    enable = mkBoolOpt false "Whether or not to enable 1password.";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password = enabled;
      _1password-gui = {
        enable = true;

        polkitPolicyOwners = [config.${namespace}.user.name];
      };
    };
    environment = {
      etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            .zen-wrapped
            .zen-beta-wrapp
            zen
            zen-beta
          '';
          mode = "0755";
        };
      };
    };
  };
}
