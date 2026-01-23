{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.zellij;
in {
  options.${namespace}.cli.zellij = with types; {
    enable = mkBoolOpt false "Enable/disable zellij";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha-lavender";
      };
      themes = import ./themes.nix;
    };

    xdg.configFile = {
      "zellij/plugins/zjstatus.wasm".source = pkgs.zellij-plugins.zjstatus;
      "zellij/plugins/zellij_forgot.wasm".source = pkgs.zellij-plugins.zellij-forgot;
      "zellij/plugins/zellij-datetime.wasm".source = pkgs.zellij-plugins.zellij-forgot;
      "zellij/config.kdl".source = ./config.kdl;
      "zellij/layouts/default.kdl".source = ./layout.kdl;
    };

    xdg.cacheFile."zellij/permissions.kdl".text = ''
      "${config.xdg.configHome}/zellij/plugins/zjstatus.wasm" {
        ReadApplicationState
        ChangeApplicationState
        RunCommands
      }
    '';
  };
}
