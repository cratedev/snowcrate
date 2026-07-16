{...}: {
  flake.modules.homeManager.xdg = {config, ...}: {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      mimeApps.enable = false;

      userDirs = {
        enable = true;
        createDirectories = false;
        # env.nix's mkDefault on the same XDG vars depends on this.
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
