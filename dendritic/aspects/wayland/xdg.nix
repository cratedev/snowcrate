{...}: {
  flake.modules.homeManager.xdg = {config, ...}: {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      mimeApps.enable = false;

      userDirs = {
        enable = true;
        createDirectories = false;
        # Explicit rather than relying on the stateVersion<26.05 legacy
        # default -- env.nix's home.sessionVariables entries for these
        # same XDG paths use mkDefault specifically because this exports
        # them too; keeping it true preserves that.
        setSessionVariables = true;
        download = "$HOME";
        documents = "$HOME";
        desktop = "$HOME";
      };

      desktopEntries."1password" = {
        name = "1Password";
        exec = "1password --ozone-platform=wayland";
        terminal = false;
        type = "Application";
        categories = ["Utility"];
      };
    };
  };
}
