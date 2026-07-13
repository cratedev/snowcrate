{...}: {
  # Consolidates two previously-separate, unconditionally-active modules
  # that overlapped (modules/nixos/system/env + modules/home/cli/env) into
  # one home-manager aspect. All of these are inherently user-level
  # concerns (editor/terminal/browser prefs, XDG paths, nh's flake
  # location), so there's no need for a parallel system-level copy.
  flake.modules.homeManager.env = {
    config,
    lib,
    ...
  }: {
    # All XDG_* vars use mkDefault: xdg.nix's own settings (cacheHome,
    # userDirs.*) make home-manager's xdg module derive several of these
    # same home.sessionVariables entries independently (confirmed so far
    # for XDG_CACHE_HOME via the core xdg module, and XDG_DESKTOP_DIR via
    # xdg.userDirs -- home.stateVersion "24.05" defaults
    # xdg.userDirs.setSessionVariables to the legacy `true`, which
    # auto-exports session vars for every configured user directory).
    # mkDefault applied uniformly here rather than per-variable as each
    # collision surfaces one at a time.
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
