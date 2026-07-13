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
    # XDG_CACHE_HOME uses mkDefault: xdg.nix sets a non-standard
    # xdg.cacheHome (~/.local/cache instead of ~/.cache), and home-manager's
    # own xdg module derives home.sessionVariables.XDG_CACHE_HOME from that
    # -- mkDefault lets that explicit, more-specific value win instead of
    # conflicting with this fallback.
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "zen";
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
      XDG_CACHE_HOME = lib.mkDefault "${config.home.homeDirectory}/.cache";
      XDG_DESKTOP_DIR = config.home.homeDirectory;
      OP_BIOMETRIC_UNLOCK_ENABLED = "true";
      NH_FLAKE = "${config.home.homeDirectory}/snowcrate";
      LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
      WGETRC = "${config.home.homeDirectory}/.config/wgetrc";
    };
  };
}
