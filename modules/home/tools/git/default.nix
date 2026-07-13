{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.git;
in {
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Enable git";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.lazygit];

    programs.git = {
      enable = true;

      # New way: use settings instead of top-level userName/userEmail
      settings = {
        user = {
          name = config.${namespace}.user.fullName;
          email = config.${namespace}.user.email;
        };

        init.defaultBranch = "master";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };

      ignores = ["result"];
      lfs = enabled;
    };
  };
}
