{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.profiles.server = {
    enable = mkBoolOpt false "Enable server profile";
  };

  config = mkIf config.${namespace}.profiles.server.enable {
    ${namespace} = {
      user.enable = true;
      xdg.enable = true;

      cli = {
        nushell.enable = true;
        fish.enable = true;
        btop.enable = true;
        zellij.enable = true;
        fzf.enable = true;
        just.enable = true;
      };

      tools = {
        nvf.enable = true;
        git.enable = true;
      };
    };
  };

  # Just enable the server profile
  ${namespace}.profiles.server.enable = true;

  home.stateVersion = "24.05";
}
