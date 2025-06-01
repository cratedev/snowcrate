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
  inherit (config.${namespace}) user;
in {
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Enable git";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.lazygit];
    programs.git = {
      enable = true;
      inherit (cfg) userName userEmail;
      ignores = ["result"];
      lfs = enabled;
    };
  };
}
