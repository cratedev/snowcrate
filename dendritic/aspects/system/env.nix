{...}: {
  flake.modules.homeManager.env = {
    config,
    lib,
    ...
  }: {
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "zen";
      XDG_CONFIG_HOME = lib.mkDefault "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = lib.mkDefault "${config.home.homeDirectory}/.local/share";
      XDG_BIN_HOME = lib.mkDefault "${config.home.homeDirectory}/.local/bin";
      XDG_CACHE_HOME = lib.mkDefault "${config.home.homeDirectory}/.cache";
      XDG_DESKTOP_DIR = lib.mkDefault config.home.homeDirectory;
      OP_BIOMETRIC_UNLOCK_ENABLED = "true";
      NH_FLAKE = "${config.home.homeDirectory}/snowcrate";
      LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
      WGETRC = "${config.home.homeDirectory}/.config/wgetrc";
    };
  };
}
