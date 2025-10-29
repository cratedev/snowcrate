{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.portals;
in {
  options.${namespace}.services.portals = with types; {
    enable = mkBoolOpt false "Whether to enable xdg-desktop-portal.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xdg-utils
    ];

    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];

      config = {
        common = {
          default = ["gtk"];
        };
        niri = {
          default = ["gtk" "wlr"];
          # Explicitly set what each portal handles
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        };
      };

      wlr = {
        enable = true;
        settings = {
          screencast = {
            # Choose one output to share or let the portal ask
            chooser_type = "simple"; # or "dmenu" if you have a dmenu-like launcher
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or"; # Optional: use slurp for region selection
          };
        };
      };
    };
  };
}
