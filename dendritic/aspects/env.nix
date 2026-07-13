{...}: {
  # Consolidates two previously-separate, unconditionally-active modules
  # that overlapped (modules/nixos/system/env + modules/home/cli/env) into
  # one home-manager aspect. All of these are inherently user-level
  # concerns (editor/terminal/browser prefs, XDG paths, nh's flake
  # location), so there's no need for a parallel system-level copy.
  flake.modules.homeManager.env = {config, ...}: {
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "zen";
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
      XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
      XDG_DESKTOP_DIR = config.home.homeDirectory;
      OP_BIOMETRIC_UNLOCK_ENABLED = "true";
      NH_FLAKE = "${config.home.homeDirectory}/snowcrate";
      LESSHISTFILE = "${config.home.homeDirectory}/.cache/less.history";
      WGETRC = "${config.home.homeDirectory}/.config/wgetrc";
    };
  };
}
