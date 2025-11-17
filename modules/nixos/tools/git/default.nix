{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.git;
in {
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure git.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git-crypt
    ];
    crate.home.extraOptions = {
      programs.git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user = {
            name = config.${namespace}.user.fullName;
            email = config.${namespace}.user.email;
          };

          init = {
            defaultBranch = "master";
          };

          pull = {
            rebase = true;
          };

          push = {
            autoSetupRemote = true;
          };
        };
      };
    };
  };
}
