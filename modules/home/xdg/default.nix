{
  config,
  lib,
  ...
}:
with lib;
with lib.crate; let
  cfg = config.crate.xdg;
in {
  options.crate.xdg = with types; {
    enable = mkBoolOpt false "Whether or not to enable xdg.";
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      mimeApps = {
        enable = false;
      };

      userDirs = {
        enable = true;
        createDirectories = false;
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
