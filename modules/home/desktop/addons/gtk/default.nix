{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.gtk;
  default-attrs = mapAttrs (_key: mkDefault);
  nested-default-attrs = mapAttrs (_key: default-attrs);
in {
  options.${namespace}.desktop.addons.gtk = with types; {
    enable = mkBoolOpt false "Whether to customize GTK and apply themes.";
    cursor = {
      name =
        mkOpt str "Bibata-Modern-Ice"
        "The name of the cursor theme to apply.";
      pkg =
        mkOpt package pkgs.bibata-cursors
        "The package to use for the cursor theme.";
      size = mkOpt int 22 "The size of the cursor.";
    };
    icon = {
      name = mkOpt str "breeze-dark" "The name of the icon theme to apply.";
      pkg =
        mkOpt package pkgs.libsForQt5.breeze-icons
        "The package to use for the icon theme.";
    };
  };
  config = mkIf cfg.enable {
    dconf = {
      enable = true;

      settings = nested-default-attrs {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          cursor-size = cfg.cursor.size;
          cursor-theme = cfg.cursor.name;
          enable-hot-corners = false;
          font-name = config.${namespace}.system.fonts.default;
          #gtk-theme = cfg.theme.name;
          icon-theme = cfg.icon.name;
        };
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
    };

    gtk = {
      enable = true;

      cursorTheme = {
        inherit (cfg.cursor) name;
        package = cfg.cursor.pkg;
      };
      iconTheme = {
        inherit (cfg.icon) name;
        package = cfg.icon.pkg;
      };
    };
  };
}
