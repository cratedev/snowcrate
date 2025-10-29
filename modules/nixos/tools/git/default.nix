{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.git;
  inherit (config.${namespace}) user;
in {
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure git.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [git];

    crate.home.extraOptions = {
      programs.git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
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
