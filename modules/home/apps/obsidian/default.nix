{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.obsidian;
in {
  options.${namespace}.apps.obsidian = with types; {
    enable = mkBoolOpt false "Enable/disable Obsidian";
  };

  config = mkIf cfg.enable {
    programs.obsidian = {
      enable = true;
      vaults = {
        whiskeyvault = {
          enable = true;
          target = "whiskeyvault";
          settings = {
            appearance = {
              theme = "obsidian";
              cssTheme = "Underwater";
              accentColor = "#746f8b";
              enabledCssSnippets = [
                "MCL Multi Column"
              ];
            };
            app = {
              alwaysUpdateLinks = true;
              readableLineLength = false;
            };
            communityPlugins = [
            ]; # so fucking broken
            corePlugins = [
              "backlink"
              "bookmarks"
              "canvas"
              "command-palette"
              "daily-notes"
              "editor-status"
              "file-explorer"
              "file-recovery"
              "global-search"
              "graph"
              "note-composer"
              "outline"
              "outgoing-link"
              "page-preview"
              "properties"
              "switcher"
              "sync"
              "tag-pane"
              "templates"
              "word-count"
            ];
          };
        };
      };
    };
  };
}
