{...}: {
  # Static config/theme data (config.kdl, layout.kdl, themes.nix) is reused
  # directly from the existing modules/home/cli/zellij directory rather than
  # duplicated -- it's plain data with no snowfall-lib dependency.
  flake.modules.homeManager.zellij = {
    config,
    pkgs,
    ...
  }: {
    programs.zellij = {
      enable = true;
      themes = import ../../modules/home/cli/zellij/themes.nix;
    };

    xdg.configFile = {
      "zellij/plugins/zjstatus.wasm".source = pkgs.zellij-plugins.zjstatus;
      "zellij/plugins/zellij_forgot.wasm".source = pkgs.zellij-plugins.zellij-forgot;
      "zellij/plugins/zellij-datetime.wasm".source = pkgs.zellij-plugins.zellij-datetime;
      "zellij/config.kdl".source = ../../modules/home/cli/zellij/config.kdl;
      "zellij/layouts/default.kdl".source = ../../modules/home/cli/zellij/layout.kdl;
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
