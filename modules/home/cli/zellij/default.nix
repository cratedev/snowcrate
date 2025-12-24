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
  inherit (config.lib.stylix) colors;
in {
  options.${namespace}.cli.zellij = with types; {
    enable = mkBoolOpt false "Enable/disable zellij";
  };

  config = mkIf cfg.enable {
    programs.zellij.enable = true;

    xdg.configFile = {
      "zellij/plugins/zjstatus.wasm".source = pkgs.zellij-plugins.zjstatus;
      "zellij/plugins/zellij_forgot.wasm".source = pkgs.zellij-plugins.zellij-forgot;
      "zellij/plugins/zellij-datetime.wasm".source = pkgs.zellij-plugins.zellij-datetime;

      "zellij/config.kdl".text = import ./config.nix {inherit colors;};
      "zellij/layouts/default.kdl".text = import ./layout.nix {inherit colors;};
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
