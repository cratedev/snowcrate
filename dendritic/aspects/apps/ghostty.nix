{...}: {
  flake.modules.homeManager.ghostty = {...}: {
    programs.ghostty = {
      enable = true;
      settings = {
        gtk-tabs-location = "hidden";
        font-size = "10";
        scrollback-limit = "10_000";
        clipboard-read = "allow";
        clipboard-paste-protection = "false";
        window-decoration = "false";
        window-padding-x = "6";
        window-padding-y = "6";
        window-padding-balance = "true";
        shell-integration = "detect";
        confirm-close-surface = "false";
        theme = "dankcolors";
      };
    };
  };
}
